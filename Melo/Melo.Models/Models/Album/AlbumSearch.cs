namespace Melo.Models
{
	public class AlbumSearch : BaseSearch
	{
		public string? Name { get; set; }

		public List<int>? ArtistIds { get; set; }

		public List<int>? GenreIds { get; set; }
	}
}
