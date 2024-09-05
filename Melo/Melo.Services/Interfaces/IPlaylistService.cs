using Melo.Models;
using Melo.Models.Models;

namespace Melo.Services.Interfaces
{
	public interface IPlaylistService : ICRUDService<PlaylistResponse, PlaylistSearchObject, PlaylistUpsert, PlaylistUpsert>
	{
		Task<MessageResponse?> RemoveSongs(int id, RemoveSongsRequest request);
		Task<MessageResponse?> ReorderSongs(int id, ReorderRequest request);
	}
}
