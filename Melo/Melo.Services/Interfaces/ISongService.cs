using Melo.Models;

namespace Melo.Services.Interfaces
{
    public interface ISongService : ICRUDService<SongResponse, SongSearch, SongInsert, SongUpdate>
	{
		Task<MessageResponse?> AddToPlaylists(int id, AddToPlaylistsRequest request);
	}
}
