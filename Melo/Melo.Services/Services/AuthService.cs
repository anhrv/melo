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

		public async Task<UserResponse?> GetUser()
		{
			int userId = GetUserId();

			User? user = await _context.Users.Include(u => u.UserRoles).ThenInclude(ur => ur.Role).FirstOrDefaultAsync(u => u.Id == userId && (bool)!u.Deleted!);

			return _mapper.Map<UserResponse>(user);
		}

		public async Task<UserResponse?> Update(AccountUpdate request)
		{
			int userId = GetUserId();

			User? user = await _context.Users.Include(u => u.UserRoles).ThenInclude(ur => ur.Role).FirstOrDefaultAsync(u => u.Id == userId && (bool)!u.Deleted!);

			if (user is not null)
			{
				_mapper.Map(request, user);

				user.ModifiedAt = DateTime.UtcNow;
				user.ModifiedBy = GetUserName();

				if (request.PasswordInput is not null)
				{
					user.Password = BCrypt.Net.BCrypt.HashPassword(request.PasswordInput);
				}

				await _context.SaveChangesAsync();

				await _context.Entry(user).Collection(e => e.UserRoles).Query().Include(ur => ur.Role).LoadAsync();
			}

			return _mapper.Map<UserResponse>(user);
		}

		public async Task<UserResponse?> Delete()
		{
			int userId = GetUserId();

			User? user = await _context.Users.Include(u => u.UserRoles).ThenInclude(ur => ur.Role).FirstOrDefaultAsync(u => u.Id == userId && (bool)!u.Deleted!);

			if (user is not null)
			{
				using var transaction = await _context.Database.BeginTransactionAsync();

				try
				{
					var playlists = _context.Playlists.Where(p => p.UserId == user.Id);
					foreach (var playlist in playlists)
					{
						var songPlaylists = _context.SongPlaylists.Where(sp => sp.PlaylistId == playlist.Id);
						_context.SongPlaylists.RemoveRange(songPlaylists);
					}
					_context.Playlists.RemoveRange(playlists);

					await _context.SaveChangesAsync();

					await transaction.CommitAsync();
				}
				catch (Exception)
				{
					await transaction.RollbackAsync();
					throw;
				}

				user.Deleted = true;
				await _context.SaveChangesAsync();
			}

			return _mapper.Map<UserResponse>(user);
		}

		public int GetUserId()
		{
			string? subClaimValue = _httpContextAccessor.HttpContext?.User?.FindFirst(JwtRegisteredClaimNames.Sub)?.Value;

			if (!int.TryParse(subClaimValue, out int userId))
			{
				throw new Exception("Sub claim is invalid or does not exist");
			}

			return userId;
		}

		public string GetUserName()
		{
			string? username = _httpContextAccessor.HttpContext?.User?.FindFirst(ClaimTypes.NameIdentifier)?.Value;

			if (username is null)
			{
				throw new Exception("Username claim is invalid or does not exist");
			}

			return username;
		}
	}
}
