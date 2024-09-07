namespace Melo.Models
{
	public class ArtistSearch : BaseSearch
	{
		public string? Name { get; set; }

		public List<int>? GenreIds { get; set; }
	}
}
