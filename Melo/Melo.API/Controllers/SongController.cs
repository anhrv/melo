using Melo.Models;
using Melo.Services.Interfaces;

namespace Melo.API.Controllers
{
	public class SongController : CRUDController<SongResponse, SongSearchObject, SongUpsert, SongUpsert>
	{
		public SongController(ISongService service) : base(service)
		{

		}
	}
}
