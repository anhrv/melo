using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IAuthService
	{
		Task<TokenResponse> Register(RegisterRequest request);
		Task<TokenResponse?> Login(LoginRequest request);
		Task<MessageResponse?> Logout();
		Task<TokenResponse?> RefreshToken(RefreshTokenRequest? request);
		Task<UserResponse?> GetUser();
		Task<UserResponse?> Update(AccountUpdate request);
		Task<MessageResponse?> UpdatePassword(PasswordUpdate request);
		Task<UserResponse?> Delete();
		int GetUserId();
		string GetUserName();
		bool IsAdmin();
	}
}
