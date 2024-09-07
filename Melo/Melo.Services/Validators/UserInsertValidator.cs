using FluentValidation;
using Melo.Models;

namespace Melo.Services.Validators
{
	public class UserInsertValidator : AbstractValidator<UserInsert>
	{
		public UserInsertValidator(ApplicationDbContext dbContext)
		{
			Include(new RegisterRequestValidator(dbContext));
		}
	}
}
