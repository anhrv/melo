using Melo.Models;
using Melo.Services.Interfaces;

namespace Melo.API.Controllers
{
	public class SongController : CRUDController<SongResponse, SongSearchObject, SongInsert, SongUpdate>
	{
		public SongController(ISongService service) : base(service)
		{

		}
	}
}
