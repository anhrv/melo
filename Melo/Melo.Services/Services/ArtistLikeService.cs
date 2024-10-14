using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace Melo.Services
{
	public class ArtistLikeService : IArtistLikeService
	{
		private readonly ApplicationDbContext _context;
		private readonly IAuthService _authService;
		private readonly IMapper _mapper;

		public ArtistLikeService(ApplicationDbContext context, IAuthService authService, IMapper mapper)
		{
			_context = context;
			_authService = authService;
			_mapper = mapper;
		}

		public async Task<PagedResponse<ArtistResponse>> GetLiked(ArtistSearch request)
		{
			int userId = _authService.GetUserId();

			int page = request.Page ?? 1;
			int pageSize = request.PageSize ?? 20;

			IQueryable<UserArtistLike> query = _context.UserArtistLikes.AsQueryable();

			query = query.Include(ual => ual.Artist)
						   .ThenInclude(a => a.ArtistGenres)
							 .ThenInclude(ag => ag.Genre)
						 .Where(ual => ual.UserId == userId);

			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(ual => ual.Artist.Name.Contains(request.Name));
			}

			if (request.GenreIds is not null && request.GenreIds.Count > 0)
			{
				query = query.Where(ual => request.GenreIds.All(gid => ual.Artist.ArtistGenres.Any(ag => ag.GenreId == gid)));
			}

			if (!string.IsNullOrEmpty(request.SortBy))
			{
				var sortingOrder = request.Ascending.HasValue && request.Ascending.Value == true ? "ascending" : "descending";
				query = query.OrderBy($"{request.SortBy} {sortingOrder}");
			}
			else
			{
				query = query.OrderBy("CreatedAt descending");
			}

			int totalItems = await query.CountAsync();
			int totalPages = totalItems > 0 ? (int)Math.Ceiling(totalItems / (double)pageSize) : 1;

			page = page > totalPages ? totalPages : page;

			query = query.Skip((page - 1) * pageSize).Take(pageSize);

			List<UserArtistLike> list = await query.ToListAsync();

			List<ArtistResponse> data = _mapper.Map<List<ArtistResponse>>(list);

			PagedResponse<ArtistResponse> pagedResponse = new PagedResponse<ArtistResponse>
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
			Artist? artist = await _context.Artists.FindAsync(id);

			if (artist is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			bool isLiked = await _context.UserArtistLikes.AnyAsync(ual => ual.ArtistId == id && ual.UserId == userId);

			return new IsLikedResponse() { IsLiked = isLiked };
		}

		public async Task<MessageResponse?> Like(int id)
		{
			Artist? artist = await _context.Artists.FindAsync(id);

			if (artist is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			bool isAlreadyLiked = await _context.UserArtistLikes.AnyAsync(ual => ual.ArtistId == id && ual.UserId == userId);

			if (isAlreadyLiked)
			{
				return new MessageResponse() { Success = false, Message = "Artist is already liked" };
			}

			UserArtistLike newUserArtistLike = new UserArtistLike()
			{
				UserId = userId,
				ArtistId = id,
				CreatedAt = DateTime.UtcNow,
			};

			await _context.UserArtistLikes.AddAsync(newUserArtistLike);

			artist.LikeCount++;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Artist liked" };
		}

		public async Task<MessageResponse?> Unlike(int id)
		{
			Artist? artist = await _context.Artists.FindAsync(id);

			if (artist is null)
			{
				return null;
			}

			int userId = _authService.GetUserId();

			UserArtistLike? userArtistLike = await _context.UserArtistLikes.FirstOrDefaultAsync(ual => ual.ArtistId == id && ual.UserId == userId);

			if (userArtistLike is null)
			{
				return new MessageResponse() { Success = false, Message = "Artist is already not liked" };
			}

			_context.UserArtistLikes.Remove(userArtistLike);

			artist.LikeCount--;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Artist unliked" };
		}
	}
}
