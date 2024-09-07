using Melo.Models;
using Melo.Services.Interfaces;

namespace Melo.API.Controllers
{
	public class AlbumController : CRUDController<AlbumResponse, AlbumSearch, AlbumUpsert, AlbumUpsert>
	{
		public AlbumController(IAlbumService service) : base(service)
		{

		}
	}
}
