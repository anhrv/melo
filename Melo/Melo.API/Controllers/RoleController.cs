using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	[Authorize(Policy = "Admin")]
	public class RoleController : CustomControllerBase
	{
		private readonly IRoleService _roleService;

		public RoleController(IRoleService roleService)
		{
			_roleService = roleService;
		}

		[HttpGet("Lov")]
		public async Task<IActionResult> GetLov()
		{
			List<LovResponse> response = await _roleService.GetLov();
			return Ok(response);
		}
	}
}
