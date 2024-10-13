using Melo.Models;

namespace Melo.Services.Interfaces
{
    public interface ISongService : ICRUDService<SongResponse, SongSearch, SongUpsert, SongUpsert>
	{
		Task<MessageResponse?> AddToPlaylists(int id, AddToPlaylistsRequest request);
		Task<MessageResponse?> SetAudio(int id, AudioFileRequest request);
		Task<MessageResponse?> SetImage(int id, ImageFileRequest request);
	}
}
