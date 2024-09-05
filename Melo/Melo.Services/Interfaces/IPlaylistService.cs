using Melo.Models;
using Melo.Models.Models;

namespace Melo.Services.Interfaces
{
	public interface IPlaylistService : ICRUDService<PlaylistResponse, PlaylistSearchObject, PlaylistUpsert, PlaylistUpsert>
	{
		Task<MessageResponse?> RemoveSong(int playlistId, int songId);
	}
}
