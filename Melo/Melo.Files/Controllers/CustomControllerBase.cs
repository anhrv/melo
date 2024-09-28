using Microsoft.AspNetCore.Mvc;

namespace Melo.Files.Controllers
{
	[ApiController]
	[Route("api/[controller]")]
	public class CustomControllerBase : ControllerBase
	{
		protected readonly IWebHostEnvironment _env;

		public CustomControllerBase(IWebHostEnvironment env)
		{
			_env = env;
		}
	}
}
