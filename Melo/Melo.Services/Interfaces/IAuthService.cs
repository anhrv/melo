using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IAuthService
	{
		Task<AuthenticationResponse> Register(RegisterRequest request);
		Task<AuthenticationResponse> Login(LoginRequest request);
		Task<UserResponse> GetCurrentUser();
	}
}
