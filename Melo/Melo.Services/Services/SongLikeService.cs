using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace Melo.Services
{
	public class SongLikeService : ISongLikeService
	{
		private readonly ApplicationDbContext _context;
		private readonly IAuthService _authService;
		private readonly IMapper _mapper;

		public SongLikeService(ApplicationDbContext context, IAuthService authService, IMapper mapper)
		{
			_context = context;
			_authService = authService;
			_mapper = mapper;
		}

		public async Task<PagedResponse<SongResponse>> GetLiked(SongSearch request)
		{
			int userId = _authService.GetUserId();
			int page = request.Page ?? 1;
			int pageSize = request.PageSize ?? 20;

			IQueryable<UserSongLike> query = _context.UserSongLikes.AsQueryable();

			query = query.Include(usl => usl.Song)
						   .ThenInclude(s => s.SongGenres)
							 .ThenInclude(sg => sg.Genre)
						 .Include(usl => usl.Song)
						   .ThenInclude(s => s.SongArtists)
							 .ThenInclude(sa => sa.Artist)
						 .Where(usl => usl.UserId == userId);

			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(usl => usl.Song.Name.Contains(request.Name));
			}

			if (request.GenreIds is not null && request.GenreIds.Count > 0)
			{
				query = query.Where(usl => request.GenreIds.All(gid => usl.Song.SongGenres.Any(sg => sg.GenreId == gid)));
			}

			if (request.ArtistIds is not null && request.ArtistIds.Count > 0)
			{
				query = query.Where(usl => request.ArtistIds.All(aid => usl.Song.SongArtists.Any(sa => sa.ArtistId == aid)));
			}

			var sortingOrder = request.Ascending.HasValue && request.Ascending.Value == true ? "ascending" : "descending";
			var sortBy = string.IsNullOrEmpty(request.SortBy) ? "CreatedAt" : request.SortBy;

			query = query.OrderBy($"{sortBy} {sortingOrder}");

			int totalItems = await query.CountAsync();
			int totalPages = totalItems > 0 ? (int)Math.Ceiling(totalItems / (double)pageSize) : 1;

			page = page > totalPages ? totalPages : page;

			query = query.Skip((page - 1) * pageSize).Take(pageSize);

			List<UserSongLike> list = await query.ToListAsync();

			List<SongResponse> data = _mapper.Map<List<SongResponse>>(list);

			PagedResponse<SongResponse> pagedResponse = new PagedResponse<SongResponse>
			{
				Data = data,
				Items = data.Count,
				TotalItems = totalItems,
				Page = page,
				PrevPage = page > 1 ? page - 1 : null,
				NextPage = page < totalPages ? page + 1 : null,
				TotalPages = totalPages
			};

			return pagedResponse;
		}

		public async Task<IsLikedResponse?> IsLiked(int id)
		{
			Song? song = await _context.Songs.FindAsync(id);

			if (song is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			bool isLiked = await _context.UserSongLikes.AnyAsync(usl => usl.SongId == id && usl.UserId == userId);

			return new IsLikedResponse() { IsLiked = isLiked };
		}

		public async Task<MessageResponse?> Like(int id)
		{
			Song? song = await _context.Songs.FindAsync(id);

			if(song is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			bool isAlreadyLiked = await _context.UserSongLikes.AnyAsync(usl => usl.SongId == id && usl.UserId == userId);
			
			if (isAlreadyLiked)
			{
				return new MessageResponse() { Success = false, Message = "Song is already liked" };
			}

			UserSongLike newUserSongLike = new UserSongLike()
			{
				UserId = userId,
				SongId = id,
				CreatedAt = DateTime.UtcNow,
			};

			await _context.UserSongLikes.AddAsync(newUserSongLike);

			song.LikeCount++;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Song liked" };
		}

		public async Task<MessageResponse?> Unlike(int id)
		{
			Song? song = await _context.Songs.FindAsync(id);

			if (song is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			UserSongLike? userSongLike = await _context.UserSongLikes.FirstOrDefaultAsync(usl => usl.SongId == id && usl.UserId == userId);

			if (userSongLike is null)
			{
				return new MessageResponse() { Success = false, Message = "Song is already not liked" };
			}

			_context.UserSongLikes.Remove(userSongLike);

			song.LikeCount--;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Song unliked" };
		}
	}
}
