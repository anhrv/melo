using Melo.Models;
using Melo.Models.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
    public class SongController : CRUDController<SongResponse, SongSearchObject, SongInsert, SongUpdate>
	{
		public SongController(ISongService service) : base(service)
		{
			
		}

		[Authorize(Policy = "User")]
		[HttpPost("{id}/Playlists")]
		public async Task<IActionResult> AddToPlaylists([FromRoute] int id, [FromBody] AddToPlaylistsRequest request)
		{
			MessageResponse? response = await (_service as ISongService).AddToPlaylists(id, request);
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return Ok(response);
		}
	}
}
