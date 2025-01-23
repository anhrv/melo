using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.API.Controllers
{
	[Authorize(Policy = "Admin")]
	public class UserController : CustomControllerBase
	{
		private readonly IUserService _userService;

		public UserController(IUserService userService)
		{
			_userService = userService;
		}

		[HttpGet]
		public virtual async Task<IActionResult> GetPaged([FromQuery] UserSearch request)
		{
			PagedResponse<UserResponse> response = await _userService.GetPaged(request);
			return Ok(response);
		}

		[HttpGet("Lov")]
		public virtual async Task<IActionResult> GetLov([FromQuery] LovSearch request)
		{
			PagedResponse<LovResponse> response = await _userService.GetLov(request);
			return Ok(response);
		}

		[HttpGet("{id}")]
		public virtual async Task<IActionResult> GetById([FromRoute] int id)
		{
			UserResponse? response = await _userService.GetById(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpPost]
		public virtual async Task<IActionResult> Create([FromBody] UserInsert request)
		{
			UserResponse response = await _userService.Create(request);
			return StatusCode((int)HttpStatusCode.Created, response);
		}

		[HttpPut("{id}")]
		public virtual async Task<IActionResult> Update([FromRoute] int id, [FromBody] UserUpdate request)
		{
			UserResponse? response = await _userService.Update(id, request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpDelete("{id}")]
		public virtual async Task<IActionResult> Delete([FromRoute] int id)
		{
			UserResponse? response = await _userService.Delete(id);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return NoContent();
		}
	}
}
