using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class ArtistService : CRUDService<Artist, ArtistResponse, ArtistSearchObject, ArtistUpsert, ArtistUpsert>, IArtistService
	{
		public ArtistService(ApplicationDbContext context, IMapper mapper, IAuthService authService)
		: base(context, mapper, authService)
		{

		}

		public override async Task<ArtistResponse?> GetById(int id)
		{
			Artist? artist = await _context.Artists.Include(a => a.ArtistGenres).ThenInclude(ag => ag.Genre).FirstOrDefaultAsync(a => a.Id == id);

			return _mapper.Map<ArtistResponse>(artist);
		}

		public override IQueryable<Artist> AddFilters(ArtistSearchObject request, IQueryable<Artist> query)
		{
			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(a => a.Name.Contains(request.Name));
			}

			if (request.GenreIds is not null && request.GenreIds.Count > 0)
			{
				query = query.Where(a => request.GenreIds.All(gid => a.ArtistGenres.Any(ag => ag.GenreId == gid)));
			}

			query = query.Include(a => a.ArtistGenres).ThenInclude(ag => ag.Genre);

			return query;
		}

		public override async Task BeforeInsert(ArtistUpsert request, Artist entity)
		{
			entity.CreatedAt = DateTime.UtcNow;
			entity.CreatedBy = _authService.GetUserName();
			//TODO: set ImageUrl
			entity.ViewCount = 0;
			entity.LikeCount = 0;

			//TODO: set CreatedBy in ArtistGenre
			if (request.GenreIds.Count > 0)
			{
				entity.ArtistGenres = request.GenreIds.Select(genreId => new ArtistGenre { 
					GenreId = genreId,
					CreatedAt = DateTime.UtcNow ,
					CreatedBy = _authService.GetUserName()
				}).ToList();
			}
		}

		public override async Task AfterInsert(ArtistUpsert request, Artist entity)
		{
			await _context.Entry(entity).Collection(e => e.ArtistGenres).Query().Include(ag => ag.Genre).LoadAsync(); 
		}

		public override async Task BeforeUpdate(ArtistUpsert request, Artist entity)
		{
			entity.ModifiedAt = DateTime.UtcNow;
			entity.ModifiedBy = _authService.GetUserName();
			//TODO: set ImageUrl

			var currentArtistGenres = await _context.ArtistGenres.Where(ag => ag.ArtistId == entity.Id).ToListAsync();

			var currentGenreIds = currentArtistGenres.Select(ag => ag.GenreId).ToList();

			var genresToRemove = currentArtistGenres.Where(ag => !request.GenreIds.Contains(ag.GenreId)).ToList();

			_context.ArtistGenres.RemoveRange(genresToRemove);

			var genresToAdd = request.GenreIds
									 .Where(gid => !currentGenreIds.Contains(gid))
									 .Select(gid => new ArtistGenre
									 {
										 GenreId = gid,
									 	 ArtistId = entity.Id,
									 	 CreatedAt = DateTime.UtcNow,
										 CreatedBy = _authService.GetUserName()
									 })
									 .ToList();

			await _context.ArtistGenres.AddRangeAsync(genresToAdd);
		}

		public override async Task AfterUpdate(ArtistUpsert request, Artist entity)
		{
			await _context.Entry(entity).Collection(e => e.ArtistGenres).Query().Include(ag => ag.Genre).LoadAsync();
		}

		public async override Task BeforeDelete(Artist entity)
		{
			using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				var albumArtists = _context.AlbumArtists.Where(aa => aa.ArtistId == entity.Id);
				_context.AlbumArtists.RemoveRange(albumArtists);

				var artistGenres = _context.ArtistGenres.Where(ag => ag.ArtistId == entity.Id);
				_context.ArtistGenres.RemoveRange(artistGenres);

				var songArtists = _context.SongArtists.Where(ag => ag.ArtistId == entity.Id);
				_context.SongArtists.RemoveRange(songArtists);

				var userArtistViews = _context.UserArtistViews.Where(uav => uav.ArtistId == entity.Id);
				_context.UserArtistViews.RemoveRange(userArtistViews);

				var userArtistLikes = _context.UserArtistLikes.Where(ual => ual.ArtistId == entity.Id);
				_context.UserArtistLikes.RemoveRange(userArtistLikes);

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
