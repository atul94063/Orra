using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Paymentapi.Data;
using Paymentapi.Services;
using System.Text.Json;

namespace Paymentapi.Controllers
{
    [ApiController]
    [Route("api/payment")]
    public class WebHookController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly RabbitMqPublisher _rabbitMqPublisher;
        public WebHookController(AppDbContext context, IConfiguration configuration, RabbitMqPublisher rabbitMqPublisher)
        {
            _context = context;
            _configuration = configuration;
            _rabbitMqPublisher = rabbitMqPublisher;
        }

        [HttpPost("webhook")]
        public async Task<IActionResult> HandleWebhook()
        {
            using var reader = new StreamReader(Request.Body);
            var payload = await reader.ReadToEndAsync();

            var receivedSignature = Request.Headers["X-Razorpay-Signature"].ToString();
            var webhookSecret = _configuration["Razorpay:WebhookSecret"];

            var isValid = VerifyWebhookSignature(payload, receivedSignature, webhookSecret!);

            if (!isValid)
            {
                return Unauthorized(new { error = "Invalid webhook signature" });
            }

            using var doc = JsonDocument.Parse(payload);
            var eventType = doc.RootElement.GetProperty("event").GetString();

            if (eventType == "payment.captured")
            {
                var orderId = doc.RootElement
                    .GetProperty("payload")
                    .GetProperty("payment")
                    .GetProperty("entity")
                    .GetProperty("order_id")
                    .GetString();

                var paymentId = doc.RootElement
                    .GetProperty("payload")
                    .GetProperty("payment")
                    .GetProperty("entity")
                    .GetProperty("id")
                    .GetString();

                var transaction = await _context.Transactions
                    .FirstOrDefaultAsync(t => t.PaymentGatewayRef == orderId);

                if (transaction != null)
                {
                    transaction.Status = "PROCESSING";
                    transaction.PaymentGatewayRef = paymentId;
                    await _context.SaveChangesAsync();

            

                    var message = new
                    {
                        transactionId = transaction.TransactionId,
                        bookingId = transaction.BookingId,
                        amount = transaction.Amount,
                        paymentId = paymentId,
                        status = "SUCCESS"
                    };

                    await _rabbitMqPublisher.PublishPaymentSuccessAsync(message);
                }
            }
            else if (eventType == "payment.failed")
            {
                var orderId = doc.RootElement
                    .GetProperty("payload")
                    .GetProperty("payment")
                    .GetProperty("entity")
                    .GetProperty("order_id")
                    .GetString();

                var transaction = await _context.Transactions
                    .FirstOrDefaultAsync(t => t.PaymentGatewayRef == orderId);

                if (transaction != null)
                {
                    transaction.Status = "FAILED";
                    await _context.SaveChangesAsync();
                }
            }

            return Ok(new { received = true });
        }

        private bool VerifyWebhookSignature(string payload, string receivedSignature, string secret)
        {
            var keyBytes = System.Text.Encoding.UTF8.GetBytes(secret);
            var payloadBytes = System.Text.Encoding.UTF8.GetBytes(payload);

            using var hmac = new System.Security.Cryptography.HMACSHA256(keyBytes);
            var hashBytes = hmac.ComputeHash(payloadBytes);
            var generatedSignature = Convert.ToHexString(hashBytes).ToLower();

            return generatedSignature == receivedSignature;
        }
    }
}
