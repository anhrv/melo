using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IGenreService : ICRUDService<GenreResponse, GenreSearch, GenreUpsert, GenreUpsert>
	{
		Task<MessageResponse?> SetImage(int id, ImageFileRequest request);
	}
}
