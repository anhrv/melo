using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class GenreUpsert
	{
		[Required(ErrorMessage = "Genre name is required")]
        public string Name { get; set; }

		public string? ImageData { get; set; }
    }
}
