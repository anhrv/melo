using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.API.Controllers
{
	public class CRUDController<TResponse, TSearch, TInsert, TUpdate> : CustomControllerBase where TSearch : BaseSearch
	{
		protected readonly ICRUDService<TResponse, TSearch, TInsert, TUpdate> _service;

		public CRUDController(ICRUDService<TResponse, TSearch, TInsert, TUpdate> service)
		{
			_service = service;
		}

		[Authorize(Policy = "AdminOrSubscribedUser")]
		[HttpGet]
		public virtual async Task<IActionResult> GetPaged([FromQuery] TSearch request)
		{
			PagedResponse<TResponse> response = await _service.GetPaged(request);
			return Ok(response);
		}

		[Authorize(Policy = "AdminOrSubscribedUser")]
		[HttpGet("Lov")]
		public virtual async Task<IActionResult> GetLov([FromQuery] LovSearch request)
		{
			PagedResponse<LovResponse> response = await _service.GetLov(request);
			return Ok(response);
		}

		[Authorize(Policy = "AdminOrSubscribedUser")]
		[HttpGet("{id}")]
		public virtual async Task<IActionResult> GetById([FromRoute] int id)
		{
			TResponse? response = await _service.GetById(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[Authorize(Policy = "Admin")]
		[HttpPost]
		public virtual async Task<IActionResult> Create([FromBody] TInsert request)
		{
			TResponse response = await _service.Create(request);
			return StatusCode((int) HttpStatusCode.Created, response);
		}

		[Authorize(Policy = "Admin")]
		[HttpPut("{id}")]
		public virtual async Task<IActionResult> Update([FromRoute] int id, [FromBody] TUpdate request)
		{
			TResponse? response = await _service.Update(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[Authorize(Policy = "Admin")]
		[HttpDelete("{id}")]
		public virtual async Task<IActionResult> Delete([FromRoute] int id)
		{
			TResponse? response = await _service.Delete(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return NoContent();
		}
	}
}
