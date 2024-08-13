using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class UserUpdate
	{
		public string? FirstName { get; set; }
		public string? LastName { get; set; }
		[Required(ErrorMessage = "Username is required")]
		public string UserName { get; set; }
		[Required(ErrorMessage = "Email is required")]
		[EmailAddress(ErrorMessage = "Email is invalid")]
		public string Email { get; set; }
		public string? Phone { get; set; }
		[MinLength(8, ErrorMessage = "Minimum password length is 8 characters")]
		public string? PasswordInput { get; set; }
		[Compare("PasswordInput", ErrorMessage = "Password confirmation is not the same as password")]
		public string? PasswordConfirm { get; set; }
		[Required(ErrorMessage = "RoleIds is required")]
		[MinLength(1, ErrorMessage = "User has to have one role")]
		[MaxLength(1, ErrorMessage = "User has to have one role")]
		public List<int> RoleIds { get; set; }
	}
}
