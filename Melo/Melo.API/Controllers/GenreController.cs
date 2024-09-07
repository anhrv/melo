using Melo.Models;
using Melo.Services.Interfaces;

namespace Melo.API.Controllers
{
	public class GenreController : CRUDController<GenreResponse,GenreSearch, GenreUpsert, GenreUpsert>
	{
		public GenreController(IGenreService service) : base(service)
		{

		}
	}
}
