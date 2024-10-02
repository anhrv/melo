using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class ArtistUpsert
	{
		[Required(ErrorMessage = "Artist name is required")]
		public string Name { get; set; }

		[NoDuplicates(ErrorMessage = "Genres have to be unique")]
		public List<int> GenreIds { get; set; } = new List<int>();
	}
}
