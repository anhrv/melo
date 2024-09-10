using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IPlaylistService : ICRUDService<PlaylistResponse, PlaylistSearch, PlaylistUpsert, PlaylistUpsert>
	{
		Task<PagedResponse<PlaylistSongResponse>?> GetPlaylistSongs(int id, SongSearch request);
		Task<MessageResponse?> RemoveSongs(int id, RemoveSongsRequest request);
		Task<MessageResponse?> ReorderSongs(int id, ReorderSongsRequest request);
	}
}
