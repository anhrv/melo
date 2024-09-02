using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IAuthService
	{
		Task<TokenResponse> Register(RegisterRequest request);
		Task<TokenResponse?> Login(LoginRequest request);
		Task<UserResponse?> GetUser();
		Task<UserResponse?> Update(AccountUpdate request);
		Task<UserResponse?> Delete();
		int GetUserId();
		string GetUserName();
	}
}
