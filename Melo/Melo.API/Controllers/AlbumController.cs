using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	public class AlbumController : CRUDController<AlbumResponse, AlbumSearch, AlbumUpsert, AlbumUpsert>
	{
		public AlbumController(IAlbumService service) : base(service)
		{

		}

		[Authorize(Policy = "Admin")]
		[HttpPost("{id}/Set-Image")]
		public async Task<IActionResult> SetImage([FromRoute] int id, [FromForm] ImageFileRequest request)
		{
			MessageResponse? response = await (_service as IAlbumService).SetImage(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}
	}
}
