using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Interfaces
{
	public interface IJWTService
	{
		TokenResponse CreateToken(User user);
	}
}
