using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class RemoveSongsRequest
	{
		[MinLength(1, ErrorMessage = "At least one song needs to be provided")]
		[NoDuplicates(ErrorMessage = "Songs have to be unique")]
		public List<int> SongIds { get; set; } = new List<int>();
	}
}
