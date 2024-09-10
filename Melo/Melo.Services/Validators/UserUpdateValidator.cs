using FluentValidation;
using Melo.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Routing;
using Microsoft.EntityFrameworkCore;
using System.Threading;

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
				.MustAsync(BeUniqueUserName)
				.WithMessage("Username is already taken.");

			RuleFor(x => x.Email)
				.MustAsync(BeUniqueEmail)
				.WithMessage("Email is already taken.");

			RuleFor(x => x.Phone)
				.MustAsync(BeUniquePhone)
				.When(x => !string.IsNullOrEmpty(x.Phone))
				.WithMessage("Phone number is already taken.");
		}

		private async Task<bool> BeUniqueUserName(string userName, CancellationToken cancellationToken)
		{
			var userId = GetUserIdFromRoute();
			return !(await _dbContext.Users.AnyAsync(u => u.UserName == userName && u.Id != userId, cancellationToken));
		}

		private async Task<bool> BeUniqueEmail(string email, CancellationToken cancellationToken)
		{
			var userId = GetUserIdFromRoute();
			return !(await _dbContext.Users.AnyAsync(u => u.Email == email && u.Id != userId, cancellationToken));
		}

		private async Task<bool> BeUniquePhone(string? phone, CancellationToken cancellationToken)
		{
			var userId = GetUserIdFromRoute();
			return !(await _dbContext.Users.AnyAsync(u => u.Phone == phone && u.Id != userId, cancellationToken));
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
