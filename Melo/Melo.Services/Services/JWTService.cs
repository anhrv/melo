using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
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

		public TokenResponse CreateToken(User user)
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

			string token = tokenHandler.WriteToken(tokenGenerator);

			TokenResponse response = new TokenResponse(){ Token = token };

			return response;
		}
	}
}
