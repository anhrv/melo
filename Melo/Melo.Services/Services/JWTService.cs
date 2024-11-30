using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace Melo.Services
{
	public class JWTService : IJWTService
	{
		private readonly IConfiguration _configuration;

		public JWTService(IConfiguration configuration)
		{
			_configuration = configuration;
		}

		public async Task<TokenModel> CreateToken(User user)
		{
			double expirationMinutes = Convert.ToDouble(_configuration["JWT:ExpirationMinutes"]);
			string issuer = _configuration["JWT:Issuer"];
			string audience = _configuration["JWT:Audience"];
			string key = _configuration["JWT:Key"];

			if (string.IsNullOrEmpty(issuer) || string.IsNullOrEmpty(audience) || string.IsNullOrEmpty(key))
			{
				throw new Exception("JWT configuration settings are missing.");
			}

			DateTimeOffset expiration = DateTimeOffset.UtcNow.AddMinutes(expirationMinutes);

			List<Claim> claims = new List<Claim> {
				new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
				new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
				new Claim(JwtRegisteredClaimNames.Iat, DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString()),
				new Claim(ClaimTypes.NameIdentifier, user.UserName!)
			};

			claims.AddRange(user.UserRoles.Select(userRole => new Claim(ClaimTypes.Role, userRole.Role.Name!)));

			SymmetricSecurityKey securityKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(key));
			SigningCredentials signingCredentials = new SigningCredentials(securityKey, SecurityAlgorithms.HmacSha256);

			JwtSecurityToken tokenGenerator = new JwtSecurityToken(
				issuer,
				audience,
				claims,
				expires: expiration.UtcDateTime,
				signingCredentials: signingCredentials
			);

			JwtSecurityTokenHandler tokenHandler = new JwtSecurityTokenHandler();

			string accessToken = tokenHandler.WriteToken(tokenGenerator);

			string refreshToken = generateRefreshToken();
			DateTime refreshTokenExpiresAt = DateTime.UtcNow.AddMinutes(Convert.ToDouble(_configuration["RefreshToken:ExpirationMinutes"]));

			TokenModel response = new TokenModel() { AccessToken = accessToken, RefreshToken = refreshToken, RefreshTokenExpiresAt = refreshTokenExpiresAt };

			return response;
		}

		public ClaimsPrincipal? GetPrincipalFromJwtToken(string token)
		{
			TokenValidationParameters tokenValidationParameters = new TokenValidationParameters()
			{
				ValidateAudience = true,
				ValidAudience = _configuration["JWT:Audience"],
				ValidateIssuer = true,
				ValidIssuer = _configuration["JWT:Issuer"],
				ValidateIssuerSigningKey = true,
				IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JWT:Key"])),
				ValidateLifetime = false,
				ClockSkew = TimeSpan.Zero
			};

			JwtSecurityTokenHandler jwtSecurityTokenHandler = new JwtSecurityTokenHandler()
			{
				MapInboundClaims = false
			};

			try
			{
				ClaimsPrincipal principal = jwtSecurityTokenHandler.ValidateToken(token, tokenValidationParameters, out SecurityToken securityToken);

				if (securityToken is not JwtSecurityToken jwtSecurityToken || !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
				{
					return null;
				}

				return principal;
			}
			catch (Exception ex)
			{
				return null;
			}
		}

		private string generateRefreshToken()
		{
			byte[] bytes = new byte[64];
			RandomNumberGenerator randomNumberGenerator = RandomNumberGenerator.Create();
			randomNumberGenerator.GetBytes(bytes);
			return Convert.ToBase64String(bytes);
		}
	}
}
