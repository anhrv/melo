using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class SongUpdate
	{
		[ValidDateOnly(ErrorMessage = "Song date of release is invalid")]
		public string? DateOfRelease { get; set; }

		[Required(ErrorMessage = "Song name is required")]
		public string Name { get; set; }

		[NoDuplicates(ErrorMessage = "Artists have to be unique")]
		public List<int> ArtistIds { get; set; } = new List<int>();

		[NoDuplicates(ErrorMessage = "Genres have to be unique")]
		public List<int> GenreIds { get; set; } = new List<int>();
	}
}
