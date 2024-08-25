using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

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
		public async Task<IActionResult> Register(RegisterRequest request)
		{ 
			TokenResponse response = await _authService.Register(request);
			return Ok(response);
		}

		[AllowAnonymous]
		[HttpPost("Login")]
		public async Task<IActionResult> Login(LoginRequest request)
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
	}
}
