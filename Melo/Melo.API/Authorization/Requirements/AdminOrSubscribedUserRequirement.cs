using Microsoft.AspNetCore.Authorization;

namespace Melo.API.Authorization
{
	public class AdminOrSubscribedUserRequirement : IAuthorizationRequirement
	{
	}

	public class AdminOrSubscribedUserHandler : AuthorizationHandler<AdminOrSubscribedUserRequirement>
	{
		protected override Task HandleRequirementAsync(AuthorizationHandlerContext context, AdminOrSubscribedUserRequirement requirement)
		{
			if (context.User.IsInRole("Admin") || (context.User.IsInRole("User") && SubscriptionUtility.IsSubscriptionActive(context.User)))
				context.Succeed(requirement);

			return Task.CompletedTask;
		}
	}
}
