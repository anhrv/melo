using FluentValidation;
using Melo.Models;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services.Validators
{
	public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
	{
		private readonly ApplicationDbContext _dbContext;

		public RegisterRequestValidator(ApplicationDbContext dbContext)
		{
			_dbContext = dbContext;

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
			return !(await _dbContext.Users.AnyAsync(u => u.UserName == userName, cancellationToken));
		}

		private async Task<bool> BeUniqueEmail(string email, CancellationToken cancellationToken)
		{
			return !(await _dbContext.Users.AnyAsync(u => u.Email == email, cancellationToken));
		}

		private async Task<bool> BeUniquePhone(string? phone, CancellationToken cancellationToken)
		{
			return !(await _dbContext.Users.AnyAsync(u => u.Phone == phone, cancellationToken));
		}
	}
}
