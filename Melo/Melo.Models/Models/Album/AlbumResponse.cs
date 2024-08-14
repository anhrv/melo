namespace Melo.Models
{
	public class AlbumResponse
	{
		public int Id { get; set; }

		public DateOnly? DateOfRelease { get; set; }

		public string? Name { get; set; }

		public string? Playtime { get; set; }

		public int? SongCount { get; set; }

		public long? LikeCount { get; set; }

		public long? ViewCount { get; set; }

		public string? ImageUrl { get; set; }

		public List<GenreResponse> Genres { get; set; } = new List<GenreResponse>();

		public List<ArtistResponse> Artists { get; set; } = new List<ArtistResponse>();

		public List<AlbumSongResponse> Songs { get; set; } = new List<AlbumSongResponse>();
	}
}
