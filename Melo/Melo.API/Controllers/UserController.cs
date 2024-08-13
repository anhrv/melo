using Melo.Models;
using Melo.Services.Interfaces;

namespace Melo.API.Controllers
{
	public class UserController : CRUDController<UserResponse, UserSearchObject, UserInsert, UserUpdate>
	{
		public UserController(IUserService service) : base(service)
		{

		}
	}
}
