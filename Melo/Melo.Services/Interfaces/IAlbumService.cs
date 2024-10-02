using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IAlbumService : ICRUDService<AlbumResponse, AlbumSearch, AlbumUpsert, AlbumUpsert>
	{
		Task<MessageResponse?> SetImage(int id, ImageFileRequest request);
	}
}
