using FluentValidation;
using Melo.Models;

namespace Melo.Services.Validators
{
	public class RegisterRequestValidator : AbstractValidator<RegisterRequest>
	{
		private readonly ApplicationDbContext _dbContext;

		public RegisterRequestValidator(ApplicationDbContext dbContext)
		{
			_dbContext = dbContext;

			RuleFor(x => x.UserName)
				.Must(BeUniqueUserName)
				.WithMessage("Username is already taken");

			RuleFor(x => x.Email)
				.Must(BeUniqueEmail)
				.WithMessage("Email is already taken");

			RuleFor(x => x.Phone)
				.Must(BeUniquePhone)
				.When(x => !string.IsNullOrEmpty(x.Phone))
				.WithMessage("Phone number is already taken");
		}

		private bool BeUniqueUserName(string userName)
		{
			return !_dbContext.Users.Any(u => u.UserName == userName);
		}

		private bool BeUniqueEmail(string email)
		{
			return !_dbContext.Users.Any(u => u.Email == email);
		}

		private bool BeUniquePhone(string? phone)
		{
			return !_dbContext.Users.Any(u => u.Phone == phone);
		}
	}
}
