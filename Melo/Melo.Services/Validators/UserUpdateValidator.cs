using FluentValidation;
using Melo.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;

namespace Melo.Services.Validators
{
	public class UserUpdateValidator : AbstractValidator<UserUpdate>
	{
		private readonly ApplicationDbContext _dbContext;
		private readonly IHttpContextAccessor _httpContextAccessor;

		public UserUpdateValidator(ApplicationDbContext dbContext, IHttpContextAccessor httpContextAccessor)
		{
			_dbContext = dbContext;
			_httpContextAccessor = httpContextAccessor;

			RuleFor(x => x.UserName)
				.Must(BeUniqueUserName)
				.WithMessage("Username is already taken");

			RuleFor(x => x.Email)
				.Must(BeUniqueEmail)
				.WithMessage("Email is already taken");
		}

		private bool BeUniqueUserName(string userName)
		{
			var userId = GetUserIdFromRoute();
			return !_dbContext.Users.Any(u => u.UserName == userName && u.Id != userId);
		}

		private bool BeUniqueEmail(string email)
		{
			var userId = GetUserIdFromRoute();
			return !_dbContext.Users.Any(u => u.Email == email && u.Id != userId);
		}

		private int GetUserIdFromRoute()
		{
			var routeData = _httpContextAccessor.HttpContext?.GetRouteData();
			if (routeData != null && routeData.Values.TryGetValue("id", out var id))
			{
				return int.Parse(id.ToString()!);
			}
			throw new Exception("User ID not found in route data.");
		}
	}
}
