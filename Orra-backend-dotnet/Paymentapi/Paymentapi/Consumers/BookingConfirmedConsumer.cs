using Microsoft.EntityFrameworkCore;
using Paymentapi.Data;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using System.Text;
using System.Text.Json;

namespace Paymentapi.Consumers
{
    public class BookingConfirmedConsumer : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly IConfiguration _configuration;
        private IConnection? _connection;
        private IChannel? _channel;

        public BookingConfirmedConsumer(IServiceProvider serviceProvider, IConfiguration configuration)
        {
            _serviceProvider = serviceProvider;
            _configuration = configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            var factory = new ConnectionFactory
            {
                Uri = new Uri(_configuration["RabbitMQ:Url"]!)
            };

            _connection = await factory.CreateConnectionAsync(stoppingToken);
            _channel = await _connection.CreateChannelAsync(cancellationToken: stoppingToken);

            var consumer = new AsyncEventingBasicConsumer(_channel);

            consumer.ReceivedAsync += async (model, ea) =>
            {
                var body = ea.Body.ToArray();
                var messageJson = Encoding.UTF8.GetString(body);

                Console.WriteLine($"[BookingConfirmedConsumer] Received: {messageJson}");

                try
                {
                    using var scope = _serviceProvider.CreateScope();
                    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();

                    using var doc = JsonDocument.Parse(messageJson);
                    var root = doc.RootElement;

                    var transactionId = root.GetProperty("transactionId").GetInt64();
                    var status = root.GetProperty("status").GetString();

                    var transaction = await context.Transactions
                        .FirstOrDefaultAsync(t => t.TransactionId == transactionId);

                    if (transaction != null)
                    {
                        if (status == "CONFIRMED")
                        {
                            transaction.Status = "CONFIRMED";
                        }
                        else if (status == "BOOKING_FAILED")
                        {
                            transaction.Status = "BOOKING_FAILED";
                        }

                        await context.SaveChangesAsync();
                        Console.WriteLine($"[BookingConfirmedConsumer] Transaction {transactionId} updated to {status}");
                    }

                    await _channel.BasicAckAsync(ea.DeliveryTag, false);
                }
                catch (Exception ex)
                {
                    Console.WriteLine($"[BookingConfirmedConsumer] Error: {ex.Message}");
                    await _channel.BasicNackAsync(ea.DeliveryTag, false, true);
                }
            };

            await _channel.BasicConsumeAsync(
                queue: "booking.confirmed.queue",
                autoAck: false,
                consumer: consumer,
                cancellationToken: stoppingToken
            );

           
            await Task.Delay(Timeout.Infinite, stoppingToken);
        }

        public override async Task StopAsync(CancellationToken cancellationToken)
        {
            if (_channel != null) await _channel.CloseAsync(cancellationToken);
            if (_connection != null) await _connection.CloseAsync(cancellationToken);
            await base.StopAsync(cancellationToken);
        }
    }
}
