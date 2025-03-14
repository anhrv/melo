using Melo.Services;
using Melo.Services.Entities;
using Stripe;
using System.Security.Claims;

namespace Melo.API.Authorization
{
	public class SubscriptionUtility
	{
		private readonly ApplicationDbContext _context;
		private readonly Stripe.SubscriptionService _subscriptionService;

		public SubscriptionUtility(ApplicationDbContext context, Stripe.SubscriptionService subscriptionService)
		{
			_context = context;
			_subscriptionService = subscriptionService;
		}

		public async Task<bool> IsSubscriptionActive(ClaimsPrincipal user)
		{
			string? subscribedClaim = user.FindFirst("Subscribed")?.Value;
			string? subscriptionEndClaim = user.FindFirst("SubscriptionEnd")?.Value;

			if (!bool.TryParse(subscribedClaim, out var isSubscribed) || !isSubscribed)
				return false;

			if (!long.TryParse(subscriptionEndClaim, out var unixTime))
				return false;

			DateTime subscriptionEnd = DateTimeOffset.FromUnixTimeSeconds(unixTime).UtcDateTime;

			if(subscriptionEnd < DateTime.UtcNow)
			{
				string? userIdClaim = user.FindFirst("sub")?.Value;
				if (!int.TryParse(userIdClaim, out int userId))
				{
					return false;
				}

				User? userEntity = await _context.Users.FindAsync(userId);
				if (userEntity == null || string.IsNullOrEmpty(userEntity.StripeSubscriptionId))
				{
					return false;
				}

				Subscription stripeSubscription = await _subscriptionService.GetAsync(userEntity.StripeSubscriptionId);

				userEntity.Subscribed = stripeSubscription?.Status is "active" or "trialing" or "past_due";
				userEntity.SubscriptionEnd = stripeSubscription?.CurrentPeriodEnd ?? userEntity.SubscriptionEnd;
				await _context.SaveChangesAsync();

				return userEntity.Subscribed ?? false;
			}

			return true;
		}
	}
}
