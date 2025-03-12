using Melo.Models;
using Microsoft.AspNetCore.Authorization.Policy;
using Microsoft.AspNetCore.Authorization;

namespace Melo.Files.Authorization
{
	public class CustomAuthorizationMiddlewareResultHandler : IAuthorizationMiddlewareResultHandler
	{
		private readonly AuthorizationMiddlewareResultHandler _defaultHandler = new();

		public async Task HandleAsync(RequestDelegate next, HttpContext context, AuthorizationPolicy policy, PolicyAuthorizationResult result)
		{
			if (result.Forbidden)
			{
				bool isSubscriptionFailure = result.AuthorizationFailure?.FailedRequirements
					.Any(r => r is SubscriptionActiveRequirement || r is AdminOrSubscribedUserRequirement) == true;

				if (isSubscriptionFailure && context.User.IsInRole("User"))
				{
					context.Response.StatusCode = 402;
					await context.Response.WriteAsJsonAsync(ErrorResponse.PaymentRequired());
					return;
				}
			}

			await _defaultHandler.HandleAsync(next, context, policy, result);
		}
	}
}
