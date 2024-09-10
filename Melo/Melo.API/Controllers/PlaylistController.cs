using Melo.Models;
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
		public async Task<IActionResult> GetPaged([FromQuery] PlaylistSearch request)
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
				return NotFound(ErrorResponse.NotFound());
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
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpDelete("{id}")]
		public async Task<IActionResult> Delete([FromRoute] int id)
		{
			PlaylistResponse? response = await _playlistService.Delete(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return NoContent();
		}

		[HttpGet("{id}/Get-Songs")]
		public async Task<IActionResult> GetPlaylistSongs([FromRoute] int id, [FromQuery] SongSearch request)
		{
			PagedResponse<PlaylistSongResponse>? response = await _playlistService.GetPlaylistSongs(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpDelete("{id}/Remove-Songs")]
		public async Task<IActionResult> RemoveSongs([FromRoute] int id, [FromBody] RemoveSongsRequest request)
		{
			MessageResponse? response = await _playlistService.RemoveSongs(id, request);
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

		[HttpPut("{id}/Reorder-Songs")]
		public async Task<IActionResult> ReorderSongs([FromRoute] int id, [FromBody] ReorderSongsRequest request)
		{
			MessageResponse? response = await _playlistService.ReorderSongs(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			if(!response.Success)
			{
				return BadRequest(response);
			}
			return Ok(response);
		}
	}
}
