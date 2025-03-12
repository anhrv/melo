using System.Security.Claims;

namespace Melo.API.Authorization
{
	public static class SubscriptionUtility
	{
		public static bool IsSubscriptionActive(ClaimsPrincipal user)
		{
			string? subscribedClaim = user.FindFirst("Subscribed")?.Value;
			string? subscriptionEndClaim = user.FindFirst("SubscriptionEnd")?.Value;

			if (!bool.TryParse(subscribedClaim, out var isSubscribed) || !isSubscribed)
				return false;

			if (!long.TryParse(subscriptionEndClaim, out var unixTime))
				return false;

			DateTime subscriptionEnd = DateTimeOffset.FromUnixTimeSeconds(unixTime).UtcDateTime;
			return subscriptionEnd > DateTime.UtcNow;
		}
	}
}
