using Melo.Models;
using Melo.Models.Models;

namespace Melo.Services.Interfaces
{
    public interface ISongService : ICRUDService<SongResponse, SongSearchObject, SongInsert, SongUpdate>
	{
		Task<MessageResponse?> AddToPlaylists(int id, AddToPlaylistsRequest request);
	}
}
