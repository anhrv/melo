using Melo.Models;
using Melo.Services.Entities;
using System.Security.Claims;

namespace Melo.Services.Interfaces
{
	public interface IJWTService
	{
		Task<TokenModel> CreateToken(User user);
		ClaimsPrincipal? GetPrincipalFromJwtToken(string token);
	}
}
