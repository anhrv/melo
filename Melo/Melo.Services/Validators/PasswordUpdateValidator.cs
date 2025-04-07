using FluentValidation;
using Melo.Models;
using Microsoft.AspNetCore.Http;
using System.IdentityModel.Tokens.Jwt;

namespace Melo.Services.Validators
{
	public class PasswordUpdateValidator : AbstractValidator<PasswordUpdate>
	{
		private readonly ApplicationDbContext _dbContext;
		private readonly IHttpContextAccessor _httpContextAccessor;

		public PasswordUpdateValidator(ApplicationDbContext dbContext, IHttpContextAccessor httpContextAccessor)
		{
			_dbContext = dbContext;
			_httpContextAccessor = httpContextAccessor;

			RuleFor(x => x.CurrentPassword)
				.Must(IsCorrectPassword)
				.WithMessage("Current password is incorrect");
		}

		private bool IsCorrectPassword(string currentPassword)
		{
			var userId = GetUserIdFromClaims();
			var user = _dbContext.Users.FirstOrDefault(u => u.Id == userId && (bool)!u.Deleted!);

			return user is not null && BCrypt.Net.BCrypt.Verify(currentPassword, user.Password);
		}

		private int GetUserIdFromClaims()
		{
			var subClaimValue = _httpContextAccessor.HttpContext?.User?.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;
			if (!int.TryParse(subClaimValue, out int userId))
			{
				throw new Exception("Sub claim is invalid or does not exist");
			}
			return userId;
		}
	}
}
