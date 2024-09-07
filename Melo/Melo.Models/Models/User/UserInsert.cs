using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class UserInsert : RegisterRequest
	{
		[MinLength(1, ErrorMessage = "User has to have at least one role")]
		[NoDuplicates(ErrorMessage = "Roles have to be unique")]
		public List<int> RoleIds { get; set; } = new List<int>();
	}
}
