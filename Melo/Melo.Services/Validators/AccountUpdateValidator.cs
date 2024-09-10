using FluentValidation;
using Melo.Models;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
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
			var userId = GetUserIdFromClaims();
			return !(await _dbContext.Users.AnyAsync(u => u.UserName == userName && u.Id != userId, cancellationToken));
		}

		private async Task<bool> BeUniqueEmail(string email, CancellationToken cancellationToken)
		{
			var userId = GetUserIdFromClaims();
			return !(await _dbContext.Users.AnyAsync(u => u.Email == email && u.Id != userId, cancellationToken));
		}

		private async Task<bool> BeUniquePhone(string? phone, CancellationToken cancellationToken)
		{
			var userId = GetUserIdFromClaims();
			return !(await _dbContext.Users.AnyAsync(u => u.Phone == phone && u.Id != userId, cancellationToken));
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
