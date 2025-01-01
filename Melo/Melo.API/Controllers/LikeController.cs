using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	[Authorize(Policy = "User")]
	public class LikeController : CustomControllerBase
	{
		private readonly ISongLikeService _songLikeService;
		private readonly IArtistLikeService _artistLikeService;
		private readonly IAlbumLikeService _albumLikeService;

        public LikeController(ISongLikeService songLikeService, IArtistLikeService artistLikeService, IAlbumLikeService albumLikeService)
        {
            _songLikeService = songLikeService;
			_artistLikeService = artistLikeService;
			_albumLikeService = albumLikeService;
        }

        [HttpGet("Song")]
        public async Task<IActionResult> GetLikedSongs([FromQuery] SongSearch request)
        {
			PagedResponse<SongResponse> response = await _songLikeService.GetLiked(request);
			return Ok(response);
		}

		[HttpGet("Song/{id}")]
		public async Task<IActionResult> IsSongLiked([FromRoute] int id)
		{
			IsLikedResponse? response = await _songLikeService.IsLiked(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpPost("Song/{id}")]
		public async Task<IActionResult> LikeSong([FromRoute] int id)
		{
			MessageResponse? response = await _songLikeService.Like(id);
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

		[HttpDelete("Song/{id}")]
		public async Task<IActionResult> UnlikeSong([FromRoute] int id)
		{
			MessageResponse? response = await _songLikeService.Unlike(id);
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

		[HttpGet("Artist")]
		public async Task<IActionResult> GetLikedArtists([FromQuery] ArtistSearch request)
		{
			PagedResponse<ArtistResponse> response = await _artistLikeService.GetLiked(request);
			return Ok(response);
		}

		[HttpGet("Artist/{id}")]
		public async Task<IActionResult> IsArtistLiked([FromRoute] int id)
		{
			IsLikedResponse? response = await _artistLikeService.IsLiked(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpPost("Artist/{id}")]
		public async Task<IActionResult> LikeArtist([FromRoute] int id)
		{
			MessageResponse? response = await _artistLikeService.Like(id);
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

		[HttpDelete("Artist/{id}")]
		public async Task<IActionResult> UnlikeArtist([FromRoute] int id)
		{
			MessageResponse? response = await _artistLikeService.Unlike(id);
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

		[HttpGet("Album")]
		public async Task<IActionResult> GetLikedAlbums([FromQuery] AlbumSearch request)
		{
			PagedResponse<AlbumResponse> response = await _albumLikeService.GetLiked(request);
			return Ok(response);
		}

		[HttpGet("Album/{id}")]
		public async Task<IActionResult> IsAlbumLiked([FromRoute] int id)
		{
			IsLikedResponse? response = await _albumLikeService.IsLiked(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpPost("Album/{id}")]
		public async Task<IActionResult> LikeAlbum([FromRoute] int id)
		{
			MessageResponse? response = await _albumLikeService.Like(id);
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

		[HttpDelete("Album/{id}")]
		public async Task<IActionResult> UnlikeAlbum([FromRoute] int id)
		{
			MessageResponse? response = await _albumLikeService.Unlike(id);
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
