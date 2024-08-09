using Melo.Models;
using Melo.Services.Interfaces;

namespace Melo.API.Controllers
{
	public class ArtistController : CRUDController<ArtistResponse, ArtistSearchObject, ArtistUpsert, ArtistUpsert>
	{
		public ArtistController(IArtistService service) : base(service)
		{

		}
	}
}
