using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class SongUpsert
	{
		[ValidDateOnly(ErrorMessage = "Song date of release is invalid")]
		public string? DateOfRelease { get; set; }
		[Required(ErrorMessage = "Song name is required")]
		public string Name { get; set; }
		[Required(ErrorMessage = "Song playtime is required")]
		[RegularExpression("^((([1-9]|[1-9]\\d*):(0\\d|[1-5]\\d))|(\\d|[1-5]\\d)):([0-5]\\d)$", ErrorMessage = "Song playtime is invalid")]
		public string Playtime { get; set; }
		public string? ImageData { get; set; }
		public string? AudioData { get; set; }
		[Required(ErrorMessage = "ArtistIds is required")]
		public List<int> ArtistIds { get; set; }
		[Required(ErrorMessage = "GenreIds is required")]
		public List<int> GenreIds { get; set; }
	}
}
