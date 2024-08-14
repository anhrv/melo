using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class SongService : CRUDService<Song, SongResponse, SongSearchObject, SongInsert, SongUpdate>, ISongService
	{
		public SongService(ApplicationDbContext context, IMapper mapper)
		: base(context, mapper)
		{

		}

		public override async Task<SongResponse?> GetById(int id)
		{
			Song? song = await _context.Songs.Include(s => s.SongGenres).ThenInclude(sg => sg.Genre).Include(s => s.SongArtists).ThenInclude(sa => sa.Artist).FirstOrDefaultAsync(s => s.Id == id);

			return _mapper.Map<SongResponse>(song);
		}

		public override IQueryable<Song> AddFilters(SongSearchObject request, IQueryable<Song> query)
		{
			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(s => s.Name.Contains(request.Name));
			}

			if (request.GenreIds is not null && request.GenreIds.Count > 0)
			{
				query = query.Where(s => request.GenreIds.All(gid => s.SongGenres.Any(sg => sg.GenreId == gid)));
			}

			if (request.ArtistIds is not null && request.ArtistIds.Count > 0)
			{
				query = query.Where(s => request.ArtistIds.All(aid => s.SongArtists.Any(sa => sa.ArtistId == aid)));
			}

			query = query.Include(s => s.SongGenres).ThenInclude(sg => sg.Genre).Include(s => s.SongArtists).ThenInclude(sa => sa.Artist);

			return query;
		}

		public override async Task BeforeInsert(SongInsert request, Song entity)
		{
			entity.CreatedAt = DateTime.UtcNow;
			//TODO: set CreatedBy
			//TODO: set ImageUrl
			//TODO: set AudioUrl
			entity.ViewCount = 0;
			entity.LikeCount = 0;

			entity.PlaytimeInSeconds = ConvertToSeconds(entity.Playtime!);

			//TODO: set CreatedBy in SongArtist
			if (request.ArtistIds.Count > 0)
			{
				entity.SongArtists = request.ArtistIds.Select(artistId => new SongArtist { ArtistId = artistId, CreatedAt = DateTime.UtcNow }).ToList();
			}

			//TODO: set CreatedBy in SongGenre
			if (request.GenreIds.Count > 0)
			{
				entity.SongGenres = request.GenreIds.Select(genreId => new SongGenre { GenreId = genreId, CreatedAt = DateTime.UtcNow }).ToList();
			}
		}

		public override async Task AfterInsert(SongInsert request, Song entity)
		{
			await _context.Entry(entity).Collection(e => e.SongGenres).Query().Include(sg => sg.Genre).LoadAsync();
			await _context.Entry(entity).Collection(e => e.SongArtists).Query().Include(sa => sa.Artist).LoadAsync();
		}

		public override async Task BeforeUpdate(SongUpdate request, Song entity)
		{
			entity.ModifiedAt = DateTime.UtcNow;
			//TODO: set ModifiedBy
			//TODO: set ImageUrl
			//TODO: set AudioUrl

			entity.PlaytimeInSeconds = ConvertToSeconds(entity.Playtime!);

			var currentSongGenres = await _context.SongGenres.Where(sg => sg.SongId == entity.Id).ToListAsync();
			var currentSongArtists = await _context.SongArtists.Where(sa => sa.SongId == entity.Id).ToListAsync();

			var currentGenreIds = currentSongGenres.Select(sg => sg.GenreId).ToList();
			var currentArtistIds = currentSongArtists.Select(sa => sa.ArtistId).ToList();

			var genresToRemove = currentSongGenres.Where(sg => !request.GenreIds.Contains(sg.GenreId)).ToList();
			var artistsToRemove = currentSongArtists.Where(sa => !request.ArtistIds.Contains(sa.ArtistId)).ToList();

			_context.SongGenres.RemoveRange(genresToRemove);
			_context.SongArtists.RemoveRange(artistsToRemove);

			var genresToAdd = request.GenreIds
									 .Where(gid => !currentGenreIds.Contains(gid))
									 .Select(gid => new SongGenre
									 {
										 GenreId = gid,
										 SongId = entity.Id,
										 CreatedAt = DateTime.UtcNow  //TODO: set createdBy
									 })
									 .ToList();

			var artistsToAdd = request.ArtistIds
									 .Where(aid => !currentArtistIds.Contains(aid))
									 .Select(aid => new SongArtist
									 {
										 ArtistId = aid,
										 SongId = entity.Id,
										 CreatedAt = DateTime.UtcNow  //TODO: set createdBy
									 })
									 .ToList();

			await _context.SongGenres.AddRangeAsync(genresToAdd);
			await _context.SongArtists.AddRangeAsync(artistsToAdd);
		}

		public override async Task AfterUpdate(SongUpdate request, Song entity)
		{
			await _context.Entry(entity).Collection(e => e.SongGenres).Query().Include(sg => sg.Genre).LoadAsync();
			await _context.Entry(entity).Collection(e => e.SongArtists).Query().Include(sa => sa.Artist).LoadAsync();
		}

		public async override Task BeforeDelete(Song entity)
		{
			using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				var songArtists = _context.SongArtists.Where(sa => sa.SongId == entity.Id);
				_context.SongArtists.RemoveRange(songArtists);

				var songGenres = _context.SongGenres.Where(sg => sg.SongId == entity.Id);
				_context.SongGenres.RemoveRange(songGenres);

				var songAlbums = _context.SongAlbums.Where(sa => sa.SongId == entity.Id);
				_context.SongAlbums.RemoveRange(songAlbums);

				var songPlaylists = _context.SongPlaylists.Where(sp => sp.SongId == entity.Id);
				_context.SongPlaylists.RemoveRange(songPlaylists);

				var userSongViews = _context.UserSongViews.Where(usv => usv.SongId == entity.Id);
				_context.UserSongViews.RemoveRange(userSongViews);

				var userSongLikes = _context.UserSongLikes.Where(usl => usl.SongId == entity.Id);
				_context.UserSongLikes.RemoveRange(userSongLikes);

				await _context.SaveChangesAsync();

				await transaction.CommitAsync();
			}
			catch (Exception)
			{
				await transaction.RollbackAsync();
				throw;
			}
		}

		private static int ConvertToSeconds(string timeString)
		{
			var parts = timeString.Split(':');

			int hours=0;
			int minutes;
			int seconds;

			if (parts.Length == 3)
			{
				hours = int.Parse(parts[0]);
				minutes = int.Parse(parts[1]);
				seconds = int.Parse(parts[2]);
			}
			else if (parts.Length == 2)
			{
				minutes = int.Parse(parts[0]);
				seconds = int.Parse(parts[1]);
			}
			else
			{
				throw new ArgumentException("Invalid time format.", nameof(timeString));
			}

			return hours * 3600 + minutes * 60 + seconds;
		}
	}
}
