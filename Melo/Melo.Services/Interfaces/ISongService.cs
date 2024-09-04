using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface ISongService : ICRUDService<SongResponse, SongSearchObject, SongInsert, SongUpdate>
	{
		Task<AddToPlaylistsResponse?> AddToPlaylists(int id, AddToPlaylistsRequest request);
	}
}
