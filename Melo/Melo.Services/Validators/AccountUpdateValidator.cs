using FluentValidation;
using Melo.Models;
using Microsoft.AspNetCore.Http;
using System.IdentityModel.Tokens.Jwt;

namespace Melo.Services.Validators
{
	public class AccountUpdateValidator : AbstractValidator<AccountUpdate>
	{
		private readonly ApplicationDbContext _dbContext;
		private readonly IHttpContextAccessor _httpContextAccessor;

		public AccountUpdateValidator(ApplicationDbContext dbContext, IHttpContextAccessor httpContextAccessor)
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
			var userId = GetUserIdFromClaims();
			return !_dbContext.Users.Any(u => u.UserName == userName && u.Id != userId);
		}

		private bool BeUniqueEmail(string email)
		{
			var userId = GetUserIdFromClaims();
			return !_dbContext.Users.Any(u => u.Email == email && u.Id != userId);
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
