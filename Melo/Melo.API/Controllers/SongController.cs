using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	public class SongController : CRUDController<SongResponse, SongSearch, SongInsert, SongUpdate>
	{
		public SongController(ISongService service) : base(service)
		{
			
		}

		[Authorize(Policy = "User")]
		[HttpPost("{id}/Add-To-Playlists")]
		public async Task<IActionResult> AddToPlaylists([FromRoute] int id, [FromBody] AddToPlaylistsRequest request)
		{
			MessageResponse? response = await (_service as ISongService).AddToPlaylists(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			if (!response.Success)
			{
				return BadRequest(response);
			}
			return Ok(response);
		}
	}
}
