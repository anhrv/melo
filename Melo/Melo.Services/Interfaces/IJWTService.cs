using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Interfaces
{
	public interface IJWTService
	{
		AuthenticationResponse CreateToken(User user);
	}
}
