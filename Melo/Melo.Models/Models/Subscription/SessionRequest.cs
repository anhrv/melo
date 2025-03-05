using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class SessionRequest
	{
		[Required(ErrorMessage = "Session ID is required")]
		public string SessionId { get; set; }
    }
}
