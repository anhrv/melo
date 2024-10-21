using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Helpers;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class AlbumService : CRUDService<Album, AlbumResponse, AlbumSearch, AlbumUpsert, AlbumUpsert>, IAlbumService
	{
		private readonly IFileService _fileService;

		public AlbumService(ApplicationDbContext context, IMapper mapper, IAuthService authService, IFileService fileService)
		: base(context, mapper, authService)
		{
			_fileService = fileService;
		}

		public override async Task<AlbumResponse?> GetById(int id)
		{
			Album? album = await _context.Albums
				.Include(a => a.AlbumGenres).ThenInclude(ag => ag.Genre)
				.Include(a => a.AlbumArtists).ThenInclude(aa => aa.Artist)
				.Include(a => a.SongAlbums).ThenInclude(sa => sa.Song)
				.FirstOrDefaultAsync(a => a.Id == id);

			if (album is null)
			{
				return null;
			}

			return _mapper.Map<AlbumResponse>(album);
		}

		public override IQueryable<Album> AddFilters(AlbumSearch request, IQueryable<Album> query)
		{
			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(a => a.Name.Contains(request.Name));
			}

			if (request.GenreIds is not null && request.GenreIds.Count > 0)
			{
				query = query.Where(a => request.GenreIds.All(gid => a.AlbumGenres.Any(ag => ag.GenreId == gid)));
			}

			if (request.ArtistIds is not null && request.ArtistIds.Count > 0)
			{
				query = query.Where(a => request.ArtistIds.All(aid => a.AlbumArtists.Any(aa => aa.ArtistId == aid)));
			}

			query = query.Include(a => a.AlbumGenres).ThenInclude(ag => ag.Genre)
						 .Include(a => a.AlbumArtists).ThenInclude(aa => aa.Artist);

			return query;
		}

		public override async Task BeforeInsert(AlbumUpsert request, Album entity)
		{
			string username = _authService.GetUserName();
			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			entity.CreatedAt = DateTime.UtcNow;
			entity.CreatedBy = username;
			entity.ViewCount = 0;
			entity.LikeCount = 0;
			entity.SongCount = request.SongIds.Count;
			entity.ImageUrl = defaultImageUrl;

			if (request.SongIds.Count > 0)
			{
				entity.SongAlbums = request.SongIds.Select((songId, index) => new SongAlbum { 
					SongId = songId, 
					SongOrder = index+1, 
					CreatedAt = DateTime.UtcNow, 
					CreatedBy = username
				}).ToList();
			}

			if (request.ArtistIds.Count > 0)
			{
				entity.AlbumArtists = request.ArtistIds.Select(artistId => new AlbumArtist { 
					ArtistId = artistId, 
					CreatedAt = DateTime.UtcNow,
					CreatedBy = username
				}).ToList();
			}

			if (request.GenreIds.Count > 0)
			{
				entity.AlbumGenres = request.GenreIds.Select(genreId => new AlbumGenre { 
					GenreId = genreId, 
					CreatedAt = DateTime.UtcNow,
					CreatedBy = username
				}).ToList();
			}
		}

		public override async Task AfterInsert(AlbumUpsert request, Album entity)
		{
			await _context.Entry(entity).Collection(e => e.AlbumGenres).Query().Include(ag => ag.Genre).LoadAsync();
			await _context.Entry(entity).Collection(e => e.AlbumArtists).Query().Include(aa => aa.Artist).LoadAsync();
			await _context.Entry(entity).Collection(e => e.SongAlbums).Query().Include(sa => sa.Song).LoadAsync();

			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			foreach (SongAlbum songAlbum in entity.SongAlbums)
			{
				if (songAlbum.Song.ImageUrl is null)
				{
					songAlbum.Song.ImageUrl = entity.ImageUrl;
				}
			}

			entity.PlaytimeInSeconds = entity.SongAlbums.Sum(sa => sa.Song.PlaytimeInSeconds);
			entity.Playtime = Utility.ConvertToPlaytime(entity.PlaytimeInSeconds);
			await _context.SaveChangesAsync();
		}

		public override async Task BeforeUpdate(AlbumUpsert request, Album entity)
		{
			string username = _authService.GetUserName();

			entity.ModifiedAt = DateTime.UtcNow;
			entity.ModifiedBy = username;
			entity.SongCount = request.SongIds.Count;

			var requestSongs = request.SongIds
				.Select((songId, index) => new { SongId = songId, SongOrder = index + 1 })
				.ToDictionary(x => x.SongId, x => x.SongOrder);

			var currentAlbumGenres = await _context.AlbumGenres.Where(ag => ag.AlbumId == entity.Id).ToListAsync();
			var currentAlbumArtists = await _context.AlbumArtists.Where(aa => aa.AlbumId == entity.Id).ToListAsync();
			var currentSongAlbums = await _context.SongAlbums.Include(sa => sa.Song).Where(sa => sa.AlbumId == entity.Id).ToListAsync();

			var currentGenreIds = currentAlbumGenres.Select(ag => ag.GenreId).ToList();
			var currentArtistIds = currentAlbumArtists.Select(aa => aa.ArtistId).ToList();
			var currentSongIds = currentSongAlbums.Select(sa => sa.SongId).ToList();

			var genresToRemove = currentAlbumGenres.Where(ag => !request.GenreIds.Contains(ag.GenreId)).ToList();
			var artistsToRemove = currentAlbumArtists.Where(aa => !request.ArtistIds.Contains(aa.ArtistId)).ToList();
			var songsToRemove = currentSongAlbums.Where(sa => !requestSongs.ContainsKey(sa.SongId)).ToList();
			var songsToUpdate = currentSongAlbums.Where(sa => requestSongs.ContainsKey(sa.SongId) && requestSongs[sa.SongId] != sa.SongOrder).ToList();

			_context.AlbumGenres.RemoveRange(genresToRemove);
			_context.AlbumArtists.RemoveRange(artistsToRemove);

			string defaultImageUrl = await _fileService.GetDefaultImageUrl();
			foreach (SongAlbum songAlbum in songsToRemove)
			{
				if (songAlbum.Song.ImageUrl is null || songAlbum.Song.ImageUrl == entity.ImageUrl)
				{
					songAlbum.Song.ImageUrl = defaultImageUrl;
				}
			}
			_context.SongAlbums.RemoveRange(songsToRemove);

			var genresToAdd = request.GenreIds
									 .Where(gid => !currentGenreIds.Contains(gid))
									 .Select(gid => new AlbumGenre
									 {
										 GenreId = gid,
										 AlbumId = entity.Id,
										 CreatedAt = DateTime.UtcNow,
										 CreatedBy = username
									 })
									 .ToList();

			var artistsToAdd = request.ArtistIds
									 .Where(aid => !currentArtistIds.Contains(aid))
									 .Select(aid => new AlbumArtist
									 {
										 ArtistId = aid,
										 AlbumId = entity.Id,
										 CreatedAt = DateTime.UtcNow,
										 CreatedBy = username
									 })
									 .ToList();

			var songsToAdd = requestSongs
									 .Where(s => !currentSongIds.Contains(s.Key))
									 .Select(s => new SongAlbum
									 {
										 SongId = s.Key,
										 AlbumId = entity.Id,
										 CreatedAt = DateTime.UtcNow,
										 CreatedBy = username,
										 SongOrder = s.Value
									 })
									 .ToList();

			foreach (var song in songsToUpdate)
			{
				song.SongOrder = requestSongs[song.SongId];
				song.ModifiedAt = DateTime.UtcNow;
				song.ModifiedBy = username;
			}

			await _context.AlbumGenres.AddRangeAsync(genresToAdd);
			await _context.AlbumArtists.AddRangeAsync(artistsToAdd);
			await _context.SongAlbums.AddRangeAsync(songsToAdd);
			_context.SongAlbums.UpdateRange(songsToUpdate);
		}

		public override async Task AfterUpdate(AlbumUpsert request, Album entity)
		{
			await _context.Entry(entity).Collection(e => e.AlbumGenres).Query().Include(ag => ag.Genre).LoadAsync();
			await _context.Entry(entity).Collection(e => e.AlbumArtists).Query().Include(aa => aa.Artist).LoadAsync();
			await _context.Entry(entity).Collection(e => e.SongAlbums).Query().Include(sa => sa.Song).LoadAsync();

			string username = _authService.GetUserName();
			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			foreach (SongAlbum songAlbum in entity.SongAlbums)
			{
				if (songAlbum.Song.ImageUrl is null || songAlbum.Song.ImageUrl == defaultImageUrl)
				{
					songAlbum.Song.ImageUrl = entity.ImageUrl;
					songAlbum.Song.ModifiedAt = DateTime.UtcNow;
					songAlbum.Song.ModifiedBy = username;
				}
			}

			entity.PlaytimeInSeconds = entity.SongAlbums.Sum(sa => sa.Song.PlaytimeInSeconds);
			entity.Playtime = Utility.ConvertToPlaytime(entity.PlaytimeInSeconds);
			await _context.SaveChangesAsync();
		}

		public async override Task BeforeDelete(Album entity)
		{ 
			List<SongAlbum> songAlbums = await _context.SongAlbums.Include(sa => sa.Song).Where(sa => sa.AlbumId == entity.Id).ToListAsync();

			using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				var albumArtists = _context.AlbumArtists.Where(aa => aa.AlbumId == entity.Id);
				_context.AlbumArtists.RemoveRange(albumArtists);

				var albumGenres = _context.AlbumGenres.Where(ag => ag.AlbumId == entity.Id);
				_context.AlbumGenres.RemoveRange(albumGenres);

				_context.SongAlbums.RemoveRange(songAlbums);

				var userAlbumViews = _context.UserAlbumViews.Where(uav => uav.AlbumId == entity.Id);
				_context.UserAlbumViews.RemoveRange(userAlbumViews);

				var userAlbumLikes = _context.UserAlbumLikes.Where(ual => ual.AlbumId == entity.Id);
				_context.UserAlbumLikes.RemoveRange(userAlbumLikes);

				await _context.SaveChangesAsync();

				await transaction.CommitAsync();
			}
			catch (Exception)
			{
				await transaction.RollbackAsync();
				throw;
			}

			string username = _authService.GetUserName();
			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			if (entity.ImageUrl is not null && entity.ImageUrl != defaultImageUrl)
			{
				foreach (SongAlbum songAlbum in songAlbums)
				{
					if (songAlbum.Song.ImageUrl == entity.ImageUrl)
					{
						songAlbum.Song.ImageUrl = defaultImageUrl;
						songAlbum.Song.ModifiedAt = DateTime.UtcNow;
						songAlbum.Song.ModifiedBy = username;
					}
				}

				await _fileService.DeleteImage(entity.Id, "Album");
			}
		}

		public async Task<MessageResponse?> SetImage(int id, ImageFileRequest request)
		{
			Album? album = await _context.Albums.Include(a => a.SongAlbums).ThenInclude(sa => sa.Song).FirstOrDefaultAsync(a => a.Id == id);

			if (album is null)
			{
				return null;
			}

			string username = _authService.GetUserName();

			string defaultImageUrl = await _fileService.GetDefaultImageUrl();
			string? initialAlbumImageUrl = album.ImageUrl;

			if (request.ImageFile is not null)
			{
				album.ImageUrl = await _fileService.UploadImage(id, "Album", request.ImageFile);
			}
			else
			{

				if (album.ImageUrl is not null && album.ImageUrl != defaultImageUrl)
				{
					await _fileService.DeleteImage(id, "Album");
				}

				album.ImageUrl = defaultImageUrl;
			}

			foreach(SongAlbum songAlbum in album.SongAlbums)
			{
				if(songAlbum.Song.ImageUrl is null || songAlbum.Song.ImageUrl == defaultImageUrl || songAlbum.Song.ImageUrl == initialAlbumImageUrl)
				{
					songAlbum.Song.ImageUrl = album.ImageUrl;
					songAlbum.Song.ModifiedAt = DateTime.UtcNow;
					songAlbum.Song.ModifiedBy = username;
				}
			}

			album.ModifiedAt = DateTime.UtcNow;
			album.ModifiedBy = username;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Image set successfully" };
		}
	}
}
