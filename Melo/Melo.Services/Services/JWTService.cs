using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;

namespace Melo.Services
{
	public class JWTService : IJWTService
	{
		public JWTService()
		{

		}

		public async Task<TokenModel> CreateToken(User user)
		{
			double expirationMinutes = Convert.ToDouble(Environment.GetEnvironmentVariable("JWT_EXPIRATION_MINUTES"));
			string issuer = Environment.GetEnvironmentVariable("JWT_ISSUER");
			string audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE");
			string key = Environment.GetEnvironmentVariable("JWT_KEY");

			if (string.IsNullOrEmpty(issuer) || string.IsNullOrEmpty(audience) || string.IsNullOrEmpty(key))
			{
				throw new Exception("JWT configuration settings are missing.");
			}

			DateTimeOffset expiration = DateTimeOffset.UtcNow.AddMinutes(expirationMinutes);

			List<Claim> claims = new List<Claim> {
				new Claim(JwtRegisteredClaimNames.Sub, user.Id.ToString()),
				new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()),
				new Claim(JwtRegisteredClaimNames.Iat, DateTimeOffset.UtcNow.ToUnixTimeSeconds().ToString()),
				new Claim(ClaimTypes.NameIdentifier, user.UserName!),
				new Claim("subscribed", user.Subscribed.ToString() ?? "false"),
			};

			if (user.SubscriptionEnd.HasValue)
			{
				claims.Add(new Claim("subscriptionEnd", new DateTimeOffset(user.SubscriptionEnd.Value).ToUnixTimeSeconds().ToString()));
			}

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
			DateTime refreshTokenExpiresAt = DateTime.UtcNow.AddMinutes(Convert.ToDouble(Environment.GetEnvironmentVariable("REFRESH_TOKEN_EXPIRATION_MINUTES")));

			TokenModel response = new TokenModel() { AccessToken = accessToken, RefreshToken = refreshToken, RefreshTokenExpiresAt = refreshTokenExpiresAt };

			return response;
		}

		public ClaimsPrincipal? GetPrincipalFromJwtToken(string token)
		{
			TokenValidationParameters tokenValidationParameters = new TokenValidationParameters()
			{
				ValidateAudience = true,
				ValidAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE"),
			    ValidateIssuer = true,
				ValidIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER"),
				ValidateIssuerSigningKey = true,
				IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable("JWT_KEY"))),
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
