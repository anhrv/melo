using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Stripe;

namespace Melo.Services
{
	public class SubscriptionService : ISubscriptionService
	{
		private readonly ApplicationDbContext _context;
		private readonly IAuthService _authService;
		private readonly IJWTService _jwtService;

		public SubscriptionService(ApplicationDbContext context, IAuthService authService, IJWTService jwtService)
		{
			_context = context;
			_authService = authService;
			_jwtService = jwtService;
		}

		public async Task<SubscriptionResponse?> CreateSubscription()
		{
			int userId = _authService.GetUserId();
			User? user = await _context.Users.FindAsync(userId);
			if (user is null)
			{
				return null;
			}

			CustomerService customerService = new CustomerService();
			Customer customer = await customerService.CreateAsync(new CustomerCreateOptions
			{
				Email = user.Email,
			});

			Stripe.SubscriptionService subscriptionService = new Stripe.SubscriptionService();
			Subscription subscription = await subscriptionService.CreateAsync(new SubscriptionCreateOptions
			{
				Customer = customer.Id,
				Items = new List<SubscriptionItemOptions>
				{
					new SubscriptionItemOptions { Price = Environment.GetEnvironmentVariable("STRIPE_PRICE_ID") }
				},
				PaymentBehavior = "default_incomplete",
				Expand = new List<string> { "latest_invoice.payment_intent" }
			});

			user.StripeSubscriptionId = subscription.Id;
			await _context.SaveChangesAsync();

			return new SubscriptionResponse()
			{
				ClientSecret = subscription.LatestInvoice.PaymentIntent.ClientSecret,
				CustomerId = customer.Id,
				SubscriptionId = subscription.Id,
			};
		}

		public async Task<TokenResponse?> ConfirmSubscription()
		{
			int userId = _authService.GetUserId();
			User? user = await _context.Users.FindAsync(userId);
			if (user is null)
			{
				return null;
			}

			if (user.StripeSubscriptionId is null || user.Subscribed == true || user.SubscriptionEnd > DateTime.UtcNow)
			{
				return null;
			}

			int maxRetries = 5;
			int initialDelayMs = 2000;
			int currentRetry = 0;

			while (currentRetry < maxRetries)
			{

				Subscription subscription = await new Stripe.SubscriptionService().GetAsync(user.StripeSubscriptionId,
												new SubscriptionGetOptions { Expand = new List<string> { "latest_invoice" } });

				if (subscription.Status == "active")
				{
					user.Subscribed = true;
					user.SubscriptionStart = subscription.CurrentPeriodStart;
					user.SubscriptionEnd = subscription.CurrentPeriodEnd;
					user.StripeCustomerId = subscription.CustomerId;
					user.StripeSubscriptionId = subscription.Id;

					TokenModel tokenModel = await _jwtService.CreateToken(user);

					user.RefreshToken = tokenModel.RefreshToken;
					user.RefreshTokenExpiresAt = tokenModel.RefreshTokenExpiresAt;

					await _context.SaveChangesAsync();

					TokenResponse response = new TokenResponse() { AccessToken = tokenModel.AccessToken, RefreshToken = tokenModel.RefreshToken };

					return response;
				}

				int delay = (int)(initialDelayMs * Math.Pow(2, currentRetry));
				await Task.Delay(delay);
				currentRetry++;
			}

			return null;
		}

		public async Task<MessageResponse?> CancelSubscription()
		{
			int userId = _authService.GetUserId();
			User? user = await _context.Users.FindAsync(userId);
			if (user is null)
			{
				return null;
			}

			if (string.IsNullOrEmpty(user.StripeSubscriptionId))
			{
				return null;
			}

			Stripe.SubscriptionService subscriptionService = new Stripe.SubscriptionService();
			Subscription subscription = await subscriptionService.CancelAsync(user.StripeSubscriptionId, new SubscriptionCancelOptions { InvoiceNow = false });

			user.Subscribed = false;
			user.SubscriptionEnd = DateTime.UtcNow;
			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Subscription cancelled successfully" };
		}
	}
}
