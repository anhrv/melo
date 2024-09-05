namespace Melo.Models
{
	public class PlaylistResponse
	{
		public int Id { get; set; }

		public string? Name { get; set; }

		public string? Playtime { get; set; }

		public int? SongCount { get; set; }

		public List<PlaylistSongResponse> Songs { get; set; } = new List<PlaylistSongResponse>();
	}
}
