namespace Melo.Models
{
	public class TokenModel
	{
		public string AccessToken { get; set; } = String.Empty;
		public string RefreshToken { get; set; } = String.Empty;
		public DateTime RefreshTokenExpiresAt {  get; set; }
	}
}
