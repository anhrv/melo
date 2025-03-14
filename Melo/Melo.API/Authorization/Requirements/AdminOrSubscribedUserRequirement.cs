using Microsoft.AspNetCore.Authorization;

namespace Melo.API.Authorization
{
	public class AdminOrSubscribedUserRequirement : IAuthorizationRequirement
	{
	}

	public class AdminOrSubscribedUserHandler : AuthorizationHandler<AdminOrSubscribedUserRequirement>
	{
		private readonly SubscriptionUtility _subscriptionUtility;

		public AdminOrSubscribedUserHandler(SubscriptionUtility subscriptionUtility)
		{
			_subscriptionUtility = subscriptionUtility;
		}

		protected override async Task HandleRequirementAsync(AuthorizationHandlerContext context, AdminOrSubscribedUserRequirement requirement)
		{
			if (context.User.IsInRole("Admin") || (context.User.IsInRole("User") && await _subscriptionUtility.IsSubscriptionActive(context.User)))
				context.Succeed(requirement);

			return;
		}
	}
}
