using Melo.Models;
using Melo.Services.Interfaces;
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

		[HttpPost("Register")]
		public async Task<IActionResult> Register(RegisterRequest request)
		{ 
			AuthenticationResponse response = await _authService.Register(request);
			return Ok(response);
		}
	}
}
