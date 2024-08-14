namespace Melo.Models
{
	public class SongResponse
	{
		public int Id { get; set; }

		public DateOnly? DateOfRelease { get; set; }

		public string? Name { get; set; }

		public string? Playtime { get; set; }

		public long? LikeCount { get; set; }

		public long? ViewCount { get; set; }

		public string? ImageUrl { get; set; }

		public string? AudioUrl { get; set; }

		public List<GenreResponse> Genres { get; set; } = new List<GenreResponse>();

		public List<ArtistResponse> Artists { get; set; } = new List<ArtistResponse>();
	}
}
