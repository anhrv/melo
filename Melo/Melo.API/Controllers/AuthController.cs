using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.API.Controllers
{
	public class AuthController : CustomControllerBase
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
				return BadRequest(ErrorResponse.BadRequest("Email or password is incorrect"));
			}
			return Ok(response);
		}

		[AllowAnonymous]
		[HttpPost("Login-Admin")]
		public async Task<IActionResult> LoginAdmin([FromBody] LoginRequest request)
		{
			TokenResponse? response = await _authService.LoginAdmin(request);
			if (response is null)
			{
				return BadRequest(ErrorResponse.BadRequest("Email or password is incorrect"));
			}
			return Ok(response);
		}

		[HttpPost("Logout")]
		public async Task<IActionResult> Logout()
		{
			MessageResponse? response = await _authService.Logout();
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[AllowAnonymous]
		[HttpPost("Refresh-Token")]
		public async Task<IActionResult> RefreshToken([FromBody] RefreshTokenRequest? request)
		{
			TokenResponse? response = await _authService.RefreshToken(request);
			if (response is null)
			{
				return Unauthorized(ErrorResponse.Unauthorized());
			}
			return Ok(response);
		}

		[HttpGet("User")]
		public async Task<IActionResult> GetUser()
		{
			UserResponse? response = await _authService.GetUser();
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpPut("User")]
		public async Task<IActionResult> Update([FromBody] AccountUpdate request)
		{
			UserResponse? response = await _authService.Update(request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpPut("User/Password")]
		public async Task<IActionResult> UpdatePassword([FromBody] PasswordUpdate request)
		{
			MessageResponse? response = await _authService.UpdatePassword(request);
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return Ok(response);
		}

		[HttpDelete("User")]
		public async Task<IActionResult> Delete()
		{
			UserResponse? response = await _authService.Delete();
			if (response is null)
			{
				return NotFound(ErrorResponse.NotFound());
			}
			return NoContent();
		}
	}
}
