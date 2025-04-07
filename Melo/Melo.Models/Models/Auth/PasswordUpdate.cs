using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class PasswordUpdate
	{
		[Required(ErrorMessage = "Current password is required")]
		public string CurrentPassword { get; set; }

		[Required(ErrorMessage = "New password is required")]
		[MinLength(8, ErrorMessage = "Minimum password length is 8 characters")]
		public string NewPassword { get; set; }

		[Compare("NewPassword", ErrorMessage = "Password confirmation is not the same as password")]
		public string? NewPasswordConfirm { get; set; }
	}
}
