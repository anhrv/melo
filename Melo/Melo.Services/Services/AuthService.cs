using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class AuthService : IAuthService
	{
		private readonly ApplicationDbContext _context;
		private readonly IMapper _mapper;
		private readonly IRoleService _roleService;
		private readonly IJWTService _jwtService;

		public AuthService(ApplicationDbContext context, IMapper mapper, IRoleService roleService, IJWTService jwtService)
		{
			_context = context;
			_mapper = mapper;
			_roleService = roleService;
			_jwtService = jwtService;
		}

		public Task<UserResponse> GetCurrentUser()
		{
			throw new NotImplementedException();
		}

		public Task<AuthenticationResponse> Login(LoginRequest request)
		{
			throw new NotImplementedException();
		}

		public async Task<AuthenticationResponse> Register(RegisterRequest request)
		{
			User user = _mapper.Map<User>(request);

			user.CreatedAt = DateTime.UtcNow;
			user.CreatedBy = request.UserName;
			user.Deleted = false;

			user.Password = BCrypt.Net.BCrypt.HashPassword(request.PasswordInput);

			int roleId = await _roleService.GetRoleIdByName("User");

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

			AuthenticationResponse response = _jwtService.CreateToken(user);

			return response;
		}
	}
}
