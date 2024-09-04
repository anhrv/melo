using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IPlaylistService : ICRUDService<PlaylistResponse, PlaylistSearchObject, PlaylistUpsert, PlaylistUpsert>
	{
	}
}
