using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Stripe.Checkout;

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

		public async Task<SessionResponse?> CreateCheckoutSession()
		{
			int userId = _authService.GetUserId();
			User? user = await _context.Users.FindAsync(userId);
			if (user is null)
			{
				return null;
			}

			string? subscriptionPriceCents = Environment.GetEnvironmentVariable("STRIPE_MONTHLY_SUBSCRIPTION_PRICE_CENTS");
			if (!long.TryParse(subscriptionPriceCents, out long subscriptionPriceCentsLong))
			{
				subscriptionPriceCentsLong = 100;
			}

			SessionCreateOptions options = new SessionCreateOptions
			{
				PaymentMethodTypes = new List<string> { "card" },
				LineItems = new List<SessionLineItemOptions>
				{
					new SessionLineItemOptions
					{
						PriceData = new SessionLineItemPriceDataOptions
						{
							Currency = "usd",
							UnitAmount = subscriptionPriceCentsLong,
							Recurring = new SessionLineItemPriceDataRecurringOptions
							{
								Interval = "month"
							},
							ProductData = new SessionLineItemPriceDataProductDataOptions
							{
								Name = "Monthly Subscription"
							}
						},
						Quantity = 1
					}
				},
				Mode = "subscription",
				SuccessUrl = "http://localhost:4200/payment-success",
				CancelUrl = "http://localhost:4200/payment-cancel"
			};

			try
			{
				SessionService service = new SessionService();
				Session session = await service.CreateAsync(options);

				user.StripeSessionId = session.Id;
				await _context.SaveChangesAsync();

				return new SessionResponse() { SessionId = session.Id };
			}
			catch (Exception ex)
			{
				return null;
			}
		}

		public async Task<TokenResponse?> ConfirmSubscription()
		{
			int userId = _authService.GetUserId();
			User? user = await _context.Users.FindAsync(userId);
			if (user is null)
			{
				return null;
			}

			if (user.StripeSessionId is null || user.Subscribed == true || user.SubscriptionEnd > DateTime.UtcNow)
			{
				return null;
			}

			try
			{
				SessionService service = new SessionService();
				Session session = await service.GetAsync(user.StripeSessionId);

				if (session is null || session.PaymentStatus != "paid")
				{
					return null;
				}

				user.Subscribed = true;
				user.SubscriptionStart = DateTime.UtcNow;
				user.SubscriptionEnd = DateTime.UtcNow.AddMonths(1);

				TokenModel tokenModel = await _jwtService.CreateToken(user);

				user.RefreshToken = tokenModel.RefreshToken;
				user.RefreshTokenExpiresAt = tokenModel.RefreshTokenExpiresAt;

				await _context.SaveChangesAsync();

				TokenResponse response = new TokenResponse() { AccessToken = tokenModel.AccessToken, RefreshToken = tokenModel.RefreshToken };

				return response;
			}
			catch (Exception ex)
			{
				return null;
			}
		}
	}
}
