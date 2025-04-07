using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class UserUpdate : AccountUpdate
	{
		[MinLength(8, ErrorMessage = "Minimum password length is 8 characters")]
		public string? NewPassword { get; set; }

		[Compare("NewPassword", ErrorMessage = "Password confirmation is not the same as password")]
		public string? PasswordConfirm { get; set; }

		[MinLength(1, ErrorMessage = "User has to have at least one role")]
		[NoDuplicates(ErrorMessage = "Roles have to be unique")]
		public List<int> RoleIds { get; set; } = new List<int>();
	}
}
