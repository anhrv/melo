using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IAuthService
	{
		Task<TokenResponse> Register(RegisterRequest request);
		Task<TokenResponse?> Login(LoginRequest request);
		Task<UserResponse?> GetUser();
		string GetUserName();
	}
}
