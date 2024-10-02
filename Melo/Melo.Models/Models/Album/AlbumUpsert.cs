using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class AlbumUpsert
	{
		[ValidDateOnly(ErrorMessage = "Album date of release is invalid")]
		public string? DateOfRelease { get; set; }

		[Required(ErrorMessage = "Album name is required")]
		public string Name { get; set; }

		[MinLength(1, ErrorMessage = "Minimum song number is 1")]
		[NoDuplicates(ErrorMessage = "Songs have to be unique")]
		public List<int> SongIds { get; set; } = new List<int>();

		[NoDuplicates(ErrorMessage = "Artists have to be unique")]
		public List<int> ArtistIds { get; set; } = new List<int>();

		[NoDuplicates(ErrorMessage = "Genres have to be unique")]
		public List<int> GenreIds { get; set; } = new List<int>();
	}
}
