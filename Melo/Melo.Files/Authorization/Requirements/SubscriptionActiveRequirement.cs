using Microsoft.AspNetCore.Authorization;

namespace Melo.Files.Authorization
{
	public class SubscriptionActiveRequirement : IAuthorizationRequirement
	{
	}

	public class SubscriptionActiveHandler : AuthorizationHandler<SubscriptionActiveRequirement>
	{
		protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, SubscriptionActiveRequirement requirement)
		{
			if (context.User.IsInRole("Admin") || SubscriptionUtility.IsSubscriptionActive(context.User))
				context.Succeed(requirement);

			return Task.CompletedTask;
		}
	}
}
