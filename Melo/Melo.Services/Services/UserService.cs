using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Stripe;

namespace Melo.Services
{
	public class UserService : CRUDService<User, UserResponse, UserSearch, UserInsert, UserUpdate>, IUserService
	{
		private readonly Stripe.SubscriptionService _subscriptionService;

		public UserService(ApplicationDbContext context, IMapper mapper, IAuthService authService, Stripe.SubscriptionService subscriptionService)
		: base(context, mapper, authService)
		{
			_subscriptionService = subscriptionService;
		}

		public override async Task<UserResponse?> GetById(int id)
		{
			User? user = await _context.Users
				.Include(u => u.UserRoles).ThenInclude(ur => ur.Role)
				.FirstOrDefaultAsync(u => u.Id == id);

			if (user is null)
			{
				return null;
			}

			return _mapper.Map<UserResponse>(user);
		}

		public override IQueryable<User> AddFilters(UserSearch request, IQueryable<User> query)
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

			if (request.Subscribed is not null)
			{
				query = query.Where(u => u.Subscribed == request.Subscribed);
			}

			if (request.Deleted is not null)
			{
				query = query.Where(u => u.Deleted == request.Deleted);
			}

			if (request.RoleIds is not null && request.RoleIds.Count > 0)
			{
				query = query.Where(u => request.RoleIds.All(rid => u.UserRoles.Any(ur => ur.RoleId == rid)));
			}

			query = query.Include(u => u.UserRoles).ThenInclude(ur => ur.Role);

			return query;
		}

		public override IQueryable<User> AddLovFilters(LovSearch request, IQueryable<User> query)
		{
			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(u => u.UserName.Contains(request.Name) || u.FirstName.Contains(request.Name) || u.LastName.Contains(request.Name));
			}

			return query;
		}

		public override async Task BeforeInsert(UserInsert request, User entity)
		{
			string username = _authService.GetUserName();

			entity.CreatedAt = DateTime.UtcNow;
			entity.CreatedBy = username;
			entity.Deleted = false;

			entity.Password = BCrypt.Net.BCrypt.HashPassword(request.PasswordInput);

			if (request.RoleIds.Count > 0)
			{
				entity.UserRoles = request.RoleIds.Select(roleId => new UserRole
				{
					RoleId = roleId,
					CreatedAt = DateTime.UtcNow,
					CreatedBy = username
				}).ToList();
			}
		}

		public override async Task AfterInsert(UserInsert request, User entity)
		{
			await _context.Entry(entity).Collection(e => e.UserRoles).Query().Include(ur => ur.Role).LoadAsync();
		}

		public override async Task BeforeUpdate(UserUpdate request, User entity)
		{
			string username = _authService.GetUserName();

			entity.ModifiedAt = DateTime.UtcNow;
			entity.ModifiedBy = username;

			if (request.NewPassword is not null)
			{
				entity.Password = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);
				entity.RefreshToken = null;
				entity.RefreshTokenExpiresAt = null;
			}

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
										 CreatedAt = DateTime.UtcNow,
										 CreatedBy = username
									 })
									 .ToList();

			await _context.UserRoles.AddRangeAsync(rolesToAdd);
		}

		public override async Task AfterUpdate(UserUpdate request, User entity)
		{
			await _context.Entry(entity).Collection(e => e.UserRoles).Query().Include(ur => ur.Role).LoadAsync();

			bool isAdmin = entity.UserRoles.Any(ur => ur.Role.Name == "Admin");
			bool isSubscribed = entity.Subscribed is not null && entity.Subscribed == true && !string.IsNullOrEmpty(entity.StripeSubscriptionId);

			if (isAdmin && isSubscribed)
			{
				try
				{
					await _subscriptionService.CancelAsync(
						entity.StripeSubscriptionId,
						new SubscriptionCancelOptions { InvoiceNow = false }
					);
				}
				catch (StripeException ex) when (ex.HttpStatusCode == System.Net.HttpStatusCode.NotFound)
				{

				}

				entity.Subscribed = false;
				entity.SubscriptionEnd = DateTime.UtcNow;

				await _context.SaveChangesAsync();
			}
		}

		public async Task<MessageResponse?> CancelSubscription(int id)
		{
			int userId = _authService.GetUserId();
			string username = _authService.GetUserName();

			User? user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id && (bool)!u.Deleted!);

			if (user is null)
			{
				return null;
			}

			bool isSubscribed = user.Subscribed is not null && user.Subscribed == true && !string.IsNullOrEmpty(user.StripeSubscriptionId);
			if (!isSubscribed)
			{
				return new MessageResponse() { Success = false, Message = "User is not subscribed already" };
			}

			try
			{
				await _subscriptionService.CancelAsync(
					user.StripeSubscriptionId,
					new SubscriptionCancelOptions { InvoiceNow = false }
				);
			}
			catch (StripeException ex) when (ex.HttpStatusCode == System.Net.HttpStatusCode.NotFound)
			{

			}

			user.Subscribed = false;
			user.SubscriptionEnd = DateTime.UtcNow;

			user.ModifiedAt = DateTime.UtcNow;
			user.ModifiedBy = username;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Subscription cancelled successfuly" };
		}

		public override async Task<UserResponse?> Delete(int id)
		{
			User? user = await _context.Users.FirstOrDefaultAsync(u => u.Id == id && (bool)!u.Deleted!);

			if (user is null)
			{
				return null;
			}

			await BeforeDelete(user);

			if (user.Subscribed is not null && user.Subscribed == true && !string.IsNullOrEmpty(user.StripeSubscriptionId))
			{
				try
				{
					await _subscriptionService.CancelAsync(
						user.StripeSubscriptionId,
						new SubscriptionCancelOptions { InvoiceNow = false }
					);
				}
				catch (StripeException ex) when (ex.HttpStatusCode == System.Net.HttpStatusCode.NotFound)
				{

				}

				user.Subscribed = false;
				user.SubscriptionEnd = DateTime.UtcNow;
			}

			user.Deleted = true;
			user.RefreshToken = null;
			user.RefreshTokenExpiresAt = null;
			await _context.SaveChangesAsync();

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
