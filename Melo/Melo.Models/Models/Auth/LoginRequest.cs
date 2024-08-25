using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class LoginRequest
	{
        [Required(ErrorMessage = "Email or username is required")]
        public string EmailUsername { get; set; }

        [Required(ErrorMessage = "Password is required")]
        public string PasswordInput { get; set; }
    }
}
