namespace Melo.Models
{
	public class ArtistResponse
	{
		public int Id { get; set; }

		public string? Name { get; set; }

		public long? LikeCount { get; set; }

		public long? ViewCount { get; set; }

		public string? ImageUrl { get; set; }

		public List<GenreResponse> Genres { get; set; } = new List<GenreResponse>();
	}
}
