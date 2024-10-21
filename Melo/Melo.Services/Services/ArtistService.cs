using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class ArtistService : CRUDService<Artist, ArtistResponse, ArtistSearch, ArtistUpsert, ArtistUpsert>, IArtistService
	{
		private readonly IFileService _fileService;

		public ArtistService(ApplicationDbContext context, IMapper mapper, IAuthService authService, IFileService fileService)
		: base(context, mapper, authService)
		{
			_fileService = fileService;
		}

		public override async Task<ArtistResponse?> GetById(int id)
		{
			Artist? artist = await _context.Artists.Include(a => a.ArtistGenres).ThenInclude(ag => ag.Genre).FirstOrDefaultAsync(a => a.Id == id);

			if (artist is null)
			{
				return null;
			}

			return _mapper.Map<ArtistResponse>(artist);
		}

		public override IQueryable<Artist> AddFilters(ArtistSearch request, IQueryable<Artist> query)
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
			string username = _authService.GetUserName();
			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			entity.CreatedAt = DateTime.UtcNow;
			entity.CreatedBy = username;
			entity.ViewCount = 0;
			entity.LikeCount = 0;
			entity.ImageUrl = defaultImageUrl;

			if (request.GenreIds.Count > 0)
			{
				entity.ArtistGenres = request.GenreIds.Select(genreId => new ArtistGenre { 
					GenreId = genreId,
					CreatedAt = DateTime.UtcNow,
					CreatedBy = username
				}).ToList();
			}
		}

		public override async Task AfterInsert(ArtistUpsert request, Artist entity)
		{
			await _context.Entry(entity).Collection(e => e.ArtistGenres).Query().Include(ag => ag.Genre).LoadAsync(); 
		}

		public override async Task BeforeUpdate(ArtistUpsert request, Artist entity)
		{
			string username = _authService.GetUserName();

			entity.ModifiedAt = DateTime.UtcNow;
			entity.ModifiedBy = username;

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
										 CreatedBy = username
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

			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			if (entity.ImageUrl is not null && entity.ImageUrl != defaultImageUrl)
			{
				await _fileService.DeleteImage(entity.Id, "Artist");
			}
		}

		public async Task<MessageResponse?> SetImage(int id, ImageFileRequest request)
		{
			Artist? artist = await _context.Artists.FindAsync(id);

			if (artist is null)
			{
				return null;
			}

			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			if (request.ImageFile is not null)
			{
				artist.ImageUrl = await _fileService.UploadImage(id, "Artist", request.ImageFile);
			}
			else
			{

				if (artist.ImageUrl is not null && artist.ImageUrl != defaultImageUrl)
				{
					await _fileService.DeleteImage(id, "Artist");
				}

				artist.ImageUrl = defaultImageUrl;
			}

			string username = _authService.GetUserName();

			artist.ModifiedAt = DateTime.UtcNow;
			artist.ModifiedBy = username;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Image set successfully" };
		}
	}
}
