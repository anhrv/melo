using System.Security.Claims;

namespace Melo.Files.Authorization
{
	public static class SubscriptionUtility
	{
		public static bool IsSubscriptionActive(ClaimsPrincipal user)
		{
			string? subscribedClaim = user.FindFirst("Subscribed")?.Value;

			if (!bool.TryParse(subscribedClaim, out var isSubscribed) || !isSubscribed)
				return false;

			return true;
		}
	}
}
