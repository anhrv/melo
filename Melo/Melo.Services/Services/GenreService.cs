using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class GenreService : CRUDService<Genre, GenreResponse, GenreSearch, GenreUpsert, GenreUpsert>, IGenreService
	{
		public GenreService(ApplicationDbContext context, IMapper mapper, IAuthService authService)
		: base(context, mapper, authService)
		{

		}

		public override IQueryable<Genre> AddFilters(GenreSearch request, IQueryable<Genre> query)
		{
			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(g => g.Name.Contains(request.Name));
			}

			return query;
		}

		public override async Task BeforeInsert(GenreUpsert request, Genre entity)
		{ 
			entity.CreatedAt = DateTime.UtcNow;
			entity.CreatedBy = _authService.GetUserName();
			//TODO: set ImageUrl
			entity.ViewCount = 0;
		}

		public override async Task BeforeUpdate(GenreUpsert request, Genre entity)
		{
			entity.ModifiedAt = DateTime.UtcNow;
			entity.ModifiedBy = _authService.GetUserName();
			//TODO: set ImageUrl
		}

		public async override Task BeforeDelete(Genre entity)
		{
			using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				var songGenres = _context.SongGenres.Where(sg => sg.GenreId == entity.Id);
				_context.SongGenres.RemoveRange(songGenres);

				var artistGenres = _context.ArtistGenres.Where(ag => ag.GenreId == entity.Id);
				_context.ArtistGenres.RemoveRange(artistGenres);

				var albumGenres = _context.AlbumGenres.Where(ag => ag.GenreId == entity.Id);
				_context.AlbumGenres.RemoveRange(albumGenres);

				var userGenreViews = _context.UserGenreViews.Where(ugv => ugv.GenreId == entity.Id);
				_context.UserGenreViews.RemoveRange(userGenreViews);

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
