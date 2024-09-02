using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.API.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class AuthController : ControllerBase
	{
		private readonly IAuthService _authService;

		public AuthController(IAuthService authService)
		{
			_authService = authService;
		}

		[AllowAnonymous]
		[HttpPost("Register")]
		public async Task<IActionResult> Register([FromBody] RegisterRequest request)
		{ 
			TokenResponse response = await _authService.Register(request);
			return StatusCode((int)HttpStatusCode.Created, response);
		}

		[AllowAnonymous]
		[HttpPost("Login")]
		public async Task<IActionResult> Login([FromBody] LoginRequest request)
		{
			TokenResponse? response = await _authService.Login(request);
			if (response is null)
			{
				return BadRequest(Errors.BadRequest("Email or password is incorrect"));
			}
			return Ok(response);
		}

		[HttpGet("User")]
		public async Task<IActionResult> GetUser()
		{
			UserResponse? response = await _authService.GetUser();
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return Ok(response);
		}

		[HttpPut("User/Update")]
		public async Task<IActionResult> Update([FromBody] AccountUpdate request)
		{
			UserResponse? response = await _authService.Update(request);
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return Ok(response);
		}

		[HttpDelete("User/Delete")]
		public async Task<IActionResult> Delete()
		{
			UserResponse? response = await _authService.Delete();
			if (response is null)
			{
				return NotFound(Errors.NotFound());
			}
			return NoContent();
		}
	}
}
