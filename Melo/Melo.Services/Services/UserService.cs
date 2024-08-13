using BCrypt.Net;
using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Xml.Linq;

namespace Melo.Services
{
	public class UserService : CRUDService<User, UserResponse, UserSearchObject, UserInsert, UserUpdate>, IUserService
	{

		public UserService(ApplicationDbContext context, IMapper mapper)
		: base(context, mapper)
		{

		}

		public override async Task<UserResponse?> GetById(int id)
		{
			User? user = await _context.Users
				.Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
				.FirstOrDefaultAsync(u => u.Id == id);

			return _mapper.Map<UserResponse>(user);
		}

		public override IQueryable<User> AddFilters(UserSearchObject request, IQueryable<User> query)
		{
			if (!string.IsNullOrWhiteSpace(request.UserName))
			{
				query = query.Where(u => u.UserName.Contains(request.UserName));
			}

			if (!string.IsNullOrWhiteSpace(request.FirstName))
			{
				query = query.Where(u => u.FirstName.Contains(request.FirstName));
			}

			if (!string.IsNullOrWhiteSpace(request.LastName))
			{
				query = query.Where(u => u.LastName.Contains(request.LastName));
			}

			if (!string.IsNullOrWhiteSpace(request.Email))
			{
				query = query.Where(u => u.Email.Contains(request.Email));
			}

			if (!string.IsNullOrWhiteSpace(request.Phone))
			{
				query = query.Where(u => u.Phone.Contains(request.Phone));
			}

			if (request.Deleted is not null)
			{
				query = query.Where(u => u.Deleted == request.Deleted);
			}

			query = query.Include(u => u.UserRoles).ThenInclude(ur => ur.Role);

			return query;
		}

		public override async Task BeforeInsert(UserInsert request, User entity)
		{
			entity.CreatedAt = DateTime.UtcNow;
			//TODO: set CreatedBy
			entity.Deleted = false;

			entity.Password = BCrypt.Net.BCrypt.HashPassword(request.PasswordInput);

			//TODO: set CreatedBy
			entity.UserRoles = request.RoleIds.Select(roleId => new UserRole { RoleId = roleId, CreatedAt = DateTime.UtcNow }).ToList();
		}

		public override async Task AfterInsert(UserInsert request, User entity)
		{
			await _context.Entry(entity).Collection(e => e.UserRoles).Query().Include(ur => ur.Role).LoadAsync();
		}

		public override async Task BeforeUpdate(UserUpdate request, User entity)
		{
			entity.ModifiedAt = DateTime.UtcNow;
			//TODO: set ModifiedBy

			if (request.PasswordInput is not null)
			{
				entity.Password = BCrypt.Net.BCrypt.HashPassword(request.PasswordInput);
			}

			//possible transcation
			var currentUserRoles = await _context.UserRoles.Where(ur => ur.UserId == entity.Id).ToListAsync();

			var currentRoleIds = currentUserRoles.Select(ur => ur.RoleId).ToList();

			var rolesToRemove = currentUserRoles.Where(ur => !request.RoleIds.Contains(ur.RoleId)).ToList();

			_context.UserRoles.RemoveRange(rolesToRemove);

			var rolesToAdd = request.RoleIds
									 .Where(rid => !currentRoleIds.Contains(rid))
									 .Select(rid => new UserRole
									 {
										 RoleId = rid,
										 UserId = entity.Id,
										 CreatedAt = DateTime.UtcNow  //TODO: set createdBy
									 })
									 .ToList();

			await _context.UserRoles.AddRangeAsync(rolesToAdd);
		}

		public override async Task AfterUpdate(UserUpdate request, User entity)
		{
			await _context.Entry(entity).Collection(e => e.UserRoles).Query().Include(ur => ur.Role).LoadAsync();
		}

		public override async Task<UserResponse?> Delete(int id)
		{
			User? user = await _context.Users.Where(u => u.Deleted == false).FirstOrDefaultAsync(u => u.Id == id);

			if (user is not null)
			{ 
				await BeforeDelete(user);
				user.Deleted = true;
				await _context.SaveChangesAsync();
			}

			return _mapper.Map<UserResponse>(user);
		}

		public async override Task BeforeDelete(User entity)
		{
			using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				var playlists = _context.Playlists.Where(p => p.UserId == entity.Id);
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
		}
	}
}
