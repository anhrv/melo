using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	public class SongController : CRUDController<SongResponse, SongSearch, SongUpsert, SongUpsert>
	{
		public SongController(ISongService service) : base(service)
		{
			
		}

		[Authorize(Policy = "SubscribedUser")]
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

		[Authorize(Policy = "Admin")]
		[HttpPost("{id}/Set-Image")]
		public async Task<IActionResult> SetImage([FromRoute] int id, [FromForm] ImageFileRequest request)
		{
			MessageResponse? response = await (_service as ISongService).SetImage(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[Authorize(Policy = "Admin")]
		[HttpPost("{id}/Set-Audio")]
		public async Task<IActionResult> SetAudio([FromRoute] int id, [FromForm] AudioFileRequest request)
		{
			MessageResponse? response = await (_service as ISongService).SetAudio(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}
	}
}
