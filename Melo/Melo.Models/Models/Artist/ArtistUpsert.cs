using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class ArtistUpsert
	{
		[Required(ErrorMessage = "Artist name is required")]
		public string Name { get; set; }
		public string? ImageData { get; set; }
		[Required(ErrorMessage = "GenreIds is required")]
		public List<int> GenreIds { get; set; }
	}
}
