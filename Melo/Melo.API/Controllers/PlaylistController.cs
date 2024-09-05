using Melo.Models;
using Melo.Models.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.API.Controllers
{
	[Authorize(Policy = "User")]
	public class PlaylistController : CustomControllerBase
	{
		private readonly IPlaylistService _playlistService;

		public PlaylistController(IPlaylistService playlistService)
		{
			_playlistService = playlistService;
		}

		[HttpGet]
		public async Task<IActionResult> GetPaged([FromQuery] PlaylistSearchObject request)
		{
			PagedResponse<PlaylistResponse> response = await _playlistService.GetPaged(request);
			return Ok(response);
		}

		[HttpGet("{id}")]
		public async Task<IActionResult> GetById([FromRoute] int id)
		{
			PlaylistResponse? response = await _playlistService.GetById(id);
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return Ok(response);
		}

		[HttpPost]
		public async Task<IActionResult> Create([FromBody] PlaylistUpsert request)
		{
			PlaylistResponse? response = await _playlistService.Create(request);
			return StatusCode((int)HttpStatusCode.Created, response);
		}

		[HttpPut("{id}")]
		public async Task<IActionResult> Update([FromRoute] int id, [FromBody] PlaylistUpsert request)
		{
			PlaylistResponse? response = await _playlistService.Update(id, request);
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return Ok(response);
		}

		[HttpDelete("{id}")]
		public async Task<IActionResult> Delete([FromRoute] int id)
		{
			PlaylistResponse? response = await _playlistService.Delete(id);
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return NoContent();
		}

		[HttpDelete("{playlistId}/song/{songId}")]
		public async Task<IActionResult> RemoveSong([FromRoute] int playlistId, [FromRoute] int songId)
		{
			MessageResponse? response = await _playlistService.RemoveSong(playlistId, songId);
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return Ok(response);
		}
	}
}
