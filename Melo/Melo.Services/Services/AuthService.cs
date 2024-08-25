using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;

namespace Melo.Services
{
	public class AuthService : IAuthService
	{
		private readonly ApplicationDbContext _context;
		private readonly IMapper _mapper;
		private readonly IJWTService _jwtService;
		private readonly IHttpContextAccessor _httpContextAccessor;

		public AuthService(ApplicationDbContext context, IMapper mapper, IJWTService jwtService, IHttpContextAccessor httpContextAccessor)
		{
			_context = context;
			_mapper = mapper;
			_jwtService = jwtService;
			_httpContextAccessor = httpContextAccessor;
		}

		public string GetUserName()
		{
			string? username = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

			if (username is null)
			{
				throw new Exception();
			}

			return username;
		}

		public async Task<UserResponse?> GetUser()
		{
			string? subClaimValue = _httpContextAccessor.HttpContext?.User?.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;

			if (!int.TryParse(subClaimValue, out int userId))
			{
				throw new Exception();
			}

			User? user = await _context.Users.Include(u => u.UserRoles).ThenInclude(ur => ur.Role).FirstOrDefaultAsync(u => u.Id == userId && (bool)!u.Deleted!);

			return _mapper.Map<UserResponse>(user);
		}
	

		public async Task<TokenResponse?> Login(LoginRequest request)
		{
			User? user = await _context.Users.Include(u => u.UserRoles).ThenInclude(ur => ur.Role).FirstOrDefaultAsync(u => (u.Email == request.EmailUsername || u.UserName == request.EmailUsername) && (bool)!u.Deleted!);
			
			if (user is null || !BCrypt.Net.BCrypt.Verify(request.PasswordInput, user.Password))
			{
				return null;
			}

			TokenResponse response = _jwtService.CreateToken(user);

			return response;
		}

		public async Task<TokenResponse> Register(RegisterRequest request)
		{
			User user = _mapper.Map<User>(request);

			user.CreatedAt = DateTime.UtcNow;
			user.CreatedBy = request.UserName;
			user.Deleted = false;

			user.Password = BCrypt.Net.BCrypt.HashPassword(request.PasswordInput);

			int roleId = await _context.Roles.Where(r => r.Name == "User").Select(r => r.Id).FirstOrDefaultAsync();

			user.UserRoles = new List<UserRole>
			{
				new UserRole
				{
					RoleId = roleId,
					CreatedAt = DateTime.UtcNow,
					CreatedBy = request.UserName
				}
			};

			await _context.Users.AddAsync(user);
			await _context.SaveChangesAsync();

			await _context.Entry(user).Collection(e => e.UserRoles).Query().Include(ur => ur.Role).LoadAsync();

			TokenResponse response = _jwtService.CreateToken(user);

			return response;
		}
	}
}
