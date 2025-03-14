using Microsoft.AspNetCore.Authorization;

namespace Melo.API.Authorization
{
	public class SubscriptionActiveRequirement : IAuthorizationRequirement
	{
	}

	public class SubscriptionActiveHandler : AuthorizationHandler<SubscriptionActiveRequirement>
	{
		private readonly SubscriptionUtility _subscriptionUtility;

		public SubscriptionActiveHandler(SubscriptionUtility subscriptionUtility)
		{
			_subscriptionUtility = subscriptionUtility;
		}

		protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, SubscriptionActiveRequirement requirement)
		{
			if (context.User.IsInRole("Admin") || await _subscriptionUtility.IsSubscriptionActive(context.User))
				context.Succeed(requirement);

			return;
		}
	}
}
