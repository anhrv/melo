using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class SongInsert
	{
		[ValidDateOnly(ErrorMessage = "Song date of release is invalid")]
		public string? DateOfRelease { get; set; }

		[Required(ErrorMessage = "Song name is required")]
		public string Name { get; set; }

		[Required(ErrorMessage = "Song playtime is required")]
		[RegularExpression("^((([1-9]|[1-9]\\d*):(0\\d|[1-5]\\d))|(\\d|[1-5]\\d)):([0-5]\\d)$", ErrorMessage = "Song playtime is invalid")]
		public string Playtime { get; set; }

		public string? ImageData { get; set; }

		[Required(ErrorMessage = "Audio file is required")]
		public string? AudioData { get; set; }

		[NoDuplicates(ErrorMessage = "Artists have to be unique")]
		public List<int> ArtistIds { get; set; } = new List<int>();

		[NoDuplicates(ErrorMessage = "Genres have to be unique")]
		public List<int> GenreIds { get; set; } = new List<int>();
	}
}
