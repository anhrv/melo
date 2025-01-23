using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace Melo.Services
{
	public class AlbumLikeService : IAlbumLikeService
	{
		private readonly ApplicationDbContext _context;
		private readonly IAuthService _authService;
		private readonly IMapper _mapper;

		public AlbumLikeService(ApplicationDbContext context, IAuthService authService, IMapper mapper)
		{
			_context = context;
			_authService = authService;
			_mapper = mapper;
		}

		public async Task<PagedResponse<AlbumResponse>> GetLiked(AlbumSearch request)
		{
			int userId = _authService.GetUserId();

			int page = request.Page ?? 1;
			int pageSize = request.PageSize ?? 20;

			IQueryable<UserAlbumLike> query = _context.UserAlbumLikes.AsQueryable();

			query = query.Include(ual => ual.Album)
						   .ThenInclude(a => a.AlbumGenres)
							 .ThenInclude(ag => ag.Genre)
						 .Include(ual => ual.Album)
						   .ThenInclude(a => a.AlbumArtists)
							 .ThenInclude(aa => aa.Artist)
						 .Where(ual => ual.UserId == userId);

			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(ual => ual.Album.Name.Contains(request.Name));
			}

			if (request.GenreIds is not null && request.GenreIds.Count > 0)
			{
				query = query.Where(ual => request.GenreIds.All(gid => ual.Album.AlbumGenres.Any(ag => ag.GenreId == gid)));
			}

			if (request.ArtistIds is not null && request.ArtistIds.Count > 0)
			{
				query = query.Where(ual => request.ArtistIds.All(aid => ual.Album.AlbumArtists.Any(aa => aa.ArtistId == aid)));
			}

			var sortingOrder = request.Ascending.HasValue && request.Ascending.Value == true ? "ascending" : "descending";
			var sortBy = string.IsNullOrEmpty(request.SortBy) ? "CreatedAt" : request.SortBy;

			query = query.OrderBy($"{sortBy} {sortingOrder}");

			int totalItems = await query.CountAsync();
			int totalPages = totalItems > 0 ? (int)Math.Ceiling(totalItems / (double)pageSize) : 1;

			page = page > totalPages ? totalPages : page;

			query = query.Skip((page - 1) * pageSize).Take(pageSize);

			List<UserAlbumLike> list = await query.ToListAsync();

			List<AlbumResponse> data = _mapper.Map<List<AlbumResponse>>(list);

			PagedResponse<AlbumResponse> pagedResponse = new PagedResponse<AlbumResponse>
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
			Album? album = await _context.Albums.FindAsync(id);

			if (album is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			bool isLiked = await _context.UserAlbumLikes.AnyAsync(ual => ual.AlbumId == id && ual.UserId == userId);

			return new IsLikedResponse() { IsLiked = isLiked };
		}

		public async Task<MessageResponse?> Like(int id)
		{
			Album? album = await _context.Albums.FindAsync(id);

			if (album is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			bool isAlreadyLiked = await _context.UserAlbumLikes.AnyAsync(ual => ual.AlbumId == id && ual.UserId == userId);

			if (isAlreadyLiked)
			{
				return new MessageResponse() { Success = false, Message = "Album is already liked" };
			}

			UserAlbumLike newUserAlbumLike = new UserAlbumLike()
			{
				UserId = userId,
				AlbumId = id,
				CreatedAt = DateTime.UtcNow,
			};

			await _context.UserAlbumLikes.AddAsync(newUserAlbumLike);

			album.LikeCount++;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Album liked" };
		}

		public async Task<MessageResponse?> Unlike(int id)
		{
			Album? album = await _context.Albums.FindAsync(id);

			if (album is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			UserAlbumLike? userAlbumLike = await _context.UserAlbumLikes.FirstOrDefaultAsync(ual => ual.AlbumId == id && ual.UserId == userId);

			if (userAlbumLike is null)
			{
				return new MessageResponse() { Success = false, Message = "Album is already not liked" };
			}

			_context.UserAlbumLikes.Remove(userAlbumLike);

			album.LikeCount--;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Album unliked" };
		}
	}
}
