using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;

namespace Melo.Services
{
	public class GenreService : CRUDService<Genre, GenreResponse, GenreSearch, GenreUpsert, GenreUpsert>, IGenreService
	{
		private readonly IFileService _fileService;

		public GenreService(ApplicationDbContext context, IMapper mapper, IAuthService authService, IFileService fileService)
		: base(context, mapper, authService)
		{
			_fileService = fileService;
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
			entity.ViewCount = 0;
		}

		public override async Task BeforeUpdate(GenreUpsert request, Genre entity)
		{
			entity.ModifiedAt = DateTime.UtcNow;
			entity.ModifiedBy = _authService.GetUserName();
		}

		public async override Task BeforeDelete(Genre entity)
		{
			if (entity.ImageUrl is not null && entity.ImageUrl != await _fileService.GetDefaultImageUrl())
			{
				await _fileService.DeleteImage(entity.Id, "Genre");
			}

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

		public async Task<MessageResponse?> SetImage(int id, ImageFileRequest request)
		{
			Genre? genre = await _context.Genres.FindAsync(id);

			if(genre is null)
			{
				return null;
			}

			string defaultImageUrl = await _fileService.GetDefaultImageUrl();
			
			if (genre.ImageUrl is null)
			{
				if (request.ImageFile is null)
				{
					genre.ImageUrl = defaultImageUrl;
				}
				else
				{
					genre.ImageUrl = await _fileService.UploadImage(id, "Genre", request.ImageFile);
				}
			}
			else if(genre.ImageUrl == defaultImageUrl)
			{
				if (request.ImageFile is not null)
				{
					genre.ImageUrl = await _fileService.UploadImage(id, "Genre", request.ImageFile);
				}
			}
            else
            {
				if (request.ImageFile is null)
				{
					await _fileService.DeleteImage(id, "Genre");
					
					genre.ImageUrl = defaultImageUrl;
				}
				else
				{
					genre.ImageUrl = await _fileService.UploadImage(id, "Genre", request.ImageFile);
				}
			}

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Image set successfully" };
		}
	}
}
