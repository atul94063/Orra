using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Paymentapi.Data;
using Paymentapi.Models;
using Paymentapi.Services;
using System.Text.Json;

namespace Paymentapi.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class PaymentController : ControllerBase
    {
        private readonly RazorPayService _razorpayService;
        private readonly AppDbContext _context;

        public PaymentController(RazorPayService razorpayService, AppDbContext context)
        {
            _razorpayService = razorpayService;
            _context = context;
        }

        public class CreateOrderRequest
        {
            public double Amount { get; set; }
            public long? BookingId { get; set; }
        }
        [HttpGet("status/{transactionId}")]
public async Task<IActionResult> GetStatus(long transactionId)
{
    var transaction = await _context.Transactions
        .FirstOrDefaultAsync(t => t.TransactionId == transactionId);

    if (transaction == null)
    {
        return NotFound(new { error = "Transaction not found" });
    }

    return Ok(new
    {
        transactionId = transaction.TransactionId,
        bookingId = transaction.BookingId,
        amount = transaction.Amount,
        status = transaction.Status
    });
}

        [HttpPost("create-order")]
        public async Task<IActionResult> CreateOrder([FromBody] CreateOrderRequest request)
        {
            var supabaseId = User.FindFirst("sub")?.Value;

            if (string.IsNullOrEmpty(supabaseId))
            {
                return Unauthorized(new { error = "No valid user identity found in token" });
            }

            try
            {
                var receipt = $"receipt_{Guid.NewGuid().ToString("N").Substring(0, 12)}";

                // Call Razorpay to create the order
                var razorpayResponseJson = await _razorpayService.CreateOrderAsync(
                    request.Amount, "INR", receipt);

                using var doc = JsonDocument.Parse(razorpayResponseJson);
                var razorpayOrderId = doc.RootElement.GetProperty("id").GetString();

                // Save a transaction record in our DB with status "pending"
                var transaction = new Transaction
                {
                    BookingId = request.BookingId,
                    Amount = request.Amount,
                    Type = "PAYMENT",
                    Status = "pending",
                    PaymentGatewayRef = razorpayOrderId,
                    CreatedAt = DateTime.UtcNow
                };

                _context.Transactions.Add(transaction);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    transactionId = transaction.TransactionId,
                    razorpayOrderId = razorpayOrderId,
                    amount = request.Amount,
                    currency = "INR"
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new { error = ex.Message });
            }
        }
    }
}
