using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.API.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class CRUDController<TModel, TSearch, TInsert, TUpdate> : ControllerBase where TSearch : BaseSearchObject
	{
		private readonly ICRUDService<TModel, TSearch, TInsert, TUpdate> _service;

		public CRUDController(ICRUDService<TModel, TSearch, TInsert, TUpdate> service)
		{
			_service = service;
		}

		[HttpGet]
		public virtual async Task<IActionResult> GetPaged([FromQuery] TSearch request)
		{
			PagedResponse<TModel> response = await _service.GetPaged(request);
			return Ok(response);
		}

		[HttpGet("{id}")]
		public virtual async Task<IActionResult> GetById([FromRoute] int id)
		{
			TModel? response = await _service.GetById(id);
			if(response is null)
				return NotFound(Errors.NotFound());
			return Ok(response);
		}

		[HttpPost]
		public virtual async Task<IActionResult> Create([FromBody] TInsert request)
		{
			TModel response = await _service.Create(request);
			return StatusCode((int) HttpStatusCode.Created, response);
		}

		[HttpPut("{id}")]
		public virtual async Task<IActionResult> Update([FromRoute] int id, [FromBody] TUpdate request)
		{
			TModel? response = await _service.Update(id, request);
			if (response is null)
				return NotFound(Errors.NotFound());
			return Ok(response);
		}

		[HttpDelete("{id}")]
		public virtual async Task<IActionResult> Delete([FromRoute] int id)
		{
			TModel? response = await _service.Delete(id);
			if (response is null)
				return NotFound(Errors.NotFound());
			return NoContent();
		}
	}
}
