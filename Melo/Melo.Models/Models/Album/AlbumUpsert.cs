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
		public string? ImageData { get; set; }
		[Required(ErrorMessage = "SongIds is required")]
		[MinLength(1, ErrorMessage = "Minimum songs number is 1")]
		[NoDuplicates(ErrorMessage = "Songs have to be unique")]
		public List<int> SongIds { get; set; }
		[Required(ErrorMessage = "ArtistIds is required")]
		[NoDuplicates(ErrorMessage = "Artists have to be unique")]
		public List<int> ArtistIds { get; set; }
		[Required(ErrorMessage = "GenreIds is required")]
		[NoDuplicates(ErrorMessage = "Genres have to be unique")]
		public List<int> GenreIds { get; set; }
	}
}
