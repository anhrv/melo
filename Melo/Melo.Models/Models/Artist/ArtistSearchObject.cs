namespace Melo.Models
{
	public class ArtistSearchObject : BaseSearchObject
	{
		public string? Name { get; set; }

		public List<int>? GenreIds { get; set; }
	}
}
