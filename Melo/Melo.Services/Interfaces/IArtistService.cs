using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IArtistService : ICRUDService<ArtistResponse, ArtistSearch, ArtistUpsert, ArtistUpsert>
	{
		Task<MessageResponse?> SetImage(int id, ImageFileRequest request);
	}
}
