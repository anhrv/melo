using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Helpers;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class SongService : CRUDService<Song, SongResponse, SongSearch, SongUpsert, SongUpsert>, ISongService
	{
		private readonly IFileService _fileService;

		public SongService(ApplicationDbContext context, IMapper mapper, IAuthService authService, IFileService fileService)
		: base(context, mapper, authService)
		{
			_fileService = fileService;
		}

		public override async Task<SongResponse?> GetById(int id)
		{
			Song? song = await _context.Songs.Include(s => s.SongGenres)
												.ThenInclude(sg => sg.Genre)
											 .Include(s => s.SongArtists)
												.ThenInclude(sa => sa.Artist)
											 .FirstOrDefaultAsync(s => s.Id == id);

			if(song is null)
			{
				return null;
			}

			return _mapper.Map<SongResponse>(song);
		}

		public override IQueryable<Song> AddFilters(SongSearch request, IQueryable<Song> query)
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

		public override async Task BeforeInsert(SongUpsert request, Song entity)
		{
			entity.CreatedAt = DateTime.UtcNow;
			entity.CreatedBy = _authService.GetUserName();
			entity.ViewCount = 0;
			entity.LikeCount = 0;

			if (request.ArtistIds.Count > 0)
			{
				entity.SongArtists = request.ArtistIds.Select(artistId => new SongArtist {
					ArtistId = artistId,
					CreatedAt = DateTime.UtcNow,
					CreatedBy = _authService.GetUserName()
				}).ToList();
			}

			if (request.GenreIds.Count > 0)
			{
				entity.SongGenres = request.GenreIds.Select(genreId => new SongGenre {
					GenreId = genreId,
					CreatedAt = DateTime.UtcNow,
					CreatedBy = _authService.GetUserName()
				}).ToList();
			}
		}

		public override async Task AfterInsert(SongUpsert request, Song entity)
		{
			await _context.Entry(entity).Collection(e => e.SongGenres).Query().Include(sg => sg.Genre).LoadAsync();
			await _context.Entry(entity).Collection(e => e.SongArtists).Query().Include(sa => sa.Artist).LoadAsync();
		}

		public override async Task BeforeUpdate(SongUpsert request, Song entity)
		{
			entity.ModifiedAt = DateTime.UtcNow;
			entity.ModifiedBy = _authService.GetUserName();

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
										 CreatedAt = DateTime.UtcNow,
										 CreatedBy = _authService.GetUserName()
									 })
									 .ToList();

			var artistsToAdd = request.ArtistIds
									 .Where(aid => !currentArtistIds.Contains(aid))
									 .Select(aid => new SongArtist
									 {
										 ArtistId = aid,
										 SongId = entity.Id,
										 CreatedAt = DateTime.UtcNow,
										 CreatedBy = _authService.GetUserName()
									 })
									 .ToList();

			await _context.SongGenres.AddRangeAsync(genresToAdd);
			await _context.SongArtists.AddRangeAsync(artistsToAdd);
		}

		public override async Task AfterUpdate(SongUpsert request, Song entity)
		{
			await _context.Entry(entity).Collection(e => e.SongGenres).Query().Include(sg => sg.Genre).LoadAsync();
			await _context.Entry(entity).Collection(e => e.SongArtists).Query().Include(sa => sa.Artist).LoadAsync();
		}

		public async override Task BeforeDelete(Song entity)
		{
			List<SongAlbum> songAlbums = await _context.SongAlbums.Include(sa => sa.Album).Where(sa => sa.SongId == entity.Id).ToListAsync();
			List<SongPlaylist> songPlaylists = await _context.SongPlaylists.Include(sp => sp.Playlist).Where(sp => sp.SongId == entity.Id).ToListAsync();

			using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				var songArtists = _context.SongArtists.Where(sa => sa.SongId == entity.Id);
				_context.SongArtists.RemoveRange(songArtists);

				var songGenres = _context.SongGenres.Where(sg => sg.SongId == entity.Id);
				_context.SongGenres.RemoveRange(songGenres);

				_context.SongAlbums.RemoveRange(songAlbums);

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
			
			if (entity.ImageUrl is not null && entity.ImageUrl != await _fileService.GetDefaultImageUrl() && entity.ImageUrl.Contains("song"))
			{
				await _fileService.DeleteImage(entity.Id, "Song");
			}

			if (entity.AudioUrl is not null)
			{
				await _fileService.DeleteAudio(entity.Id);
			}

			foreach (SongAlbum songAlbum in songAlbums)
			{

				songAlbum.Album.PlaytimeInSeconds -= entity.PlaytimeInSeconds;
				songAlbum.Album.Playtime = Utility.ConvertToPlaytime(songAlbum.Album.PlaytimeInSeconds);
				songAlbum.Album.SongCount--;
				songAlbum.Album.ModifiedAt = DateTime.UtcNow;
				songAlbum.Album.ModifiedBy = _authService.GetUserName();
			}

			foreach (SongPlaylist songPlaylist in songPlaylists)
			{
				songPlaylist.Playlist.PlaytimeInSeconds -= entity.PlaytimeInSeconds;
				songPlaylist.Playlist.Playtime = Utility.ConvertToPlaytime(songPlaylist.Playlist.PlaytimeInSeconds);
				songPlaylist.Playlist.SongCount--;
				songPlaylist.Playlist.ModifiedAt = DateTime.UtcNow;
			}
		}

		public async Task<MessageResponse?> AddToPlaylists(int songId, AddToPlaylistsRequest request)
		{
			Song? song = await _context.Songs.FindAsync(songId);

			if (song is null)
			{
				return null;
			}

			List<Playlist> validPlaylists = await _context.Playlists
															.Include(p => p.SongPlaylists)
															.Where(p => p.UserId == _authService.GetUserId() && request.PlaylistIds.Contains(p.Id))
															.ToListAsync();

			if (validPlaylists.Count != request.PlaylistIds.Count)
			{
				return new MessageResponse() { Success = false, Message = "Invalid playlists provided" };
			}

			foreach (Playlist playlist in validPlaylists)
			{
				SongPlaylist? songPlaylist = playlist.SongPlaylists.FirstOrDefault(sp => sp.SongId == songId);

				if (songPlaylist is null)
				{
					playlist.SongPlaylists.Add(new SongPlaylist
					{
						SongId = songId,
						CreatedAt = DateTime.UtcNow,
						SongOrder = playlist.SongPlaylists.Count + 1
					});

					playlist.PlaytimeInSeconds += song.PlaytimeInSeconds;
					playlist.Playtime = Utility.ConvertToPlaytime(playlist.PlaytimeInSeconds);
					playlist.SongCount++;
				}
				else
				{
					await _context.SongPlaylists
						.Where(sp => sp.PlaylistId == playlist.Id && sp.SongOrder > songPlaylist.SongOrder)
						.ExecuteUpdateAsync(sp => sp.SetProperty(sp => sp.SongOrder, sp => sp.SongOrder - 1)
													.SetProperty(sp => sp.ModifiedAt, sp => DateTime.UtcNow));

					songPlaylist.SongOrder = playlist.SongPlaylists.Count;
					songPlaylist.ModifiedAt = DateTime.UtcNow;
				}

				playlist.ModifiedAt = DateTime.UtcNow;
			}

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Song added to playlists" };
		}

		public async Task<MessageResponse?> SetAudio(int id, AudioFileRequest request)
		{
			Song? song = await _context.Songs
										.Include(s => s.SongAlbums)
											.ThenInclude(sa => sa.Album)
										.Include(s => s.SongPlaylists)
											.ThenInclude(sp => sp.Playlist)
										.FirstOrDefaultAsync(s => s.Id == id);

			if (song is null)
			{
				return null;
			}

			int songOldPlaytimeInSeconds = song.PlaytimeInSeconds ?? 0;

			song.AudioUrl = await _fileService.UploadAudio(id, request.AudioFile!);

			song.Playtime = Utility.GetAudioFilePlaytime(request.AudioFile!);
			song.PlaytimeInSeconds = Utility.ConvertToSeconds(song.Playtime);

			foreach (SongAlbum songAlbum in song.SongAlbums)
			{

				songAlbum.Album.PlaytimeInSeconds -= songOldPlaytimeInSeconds;
				songAlbum.Album.PlaytimeInSeconds += song.PlaytimeInSeconds;
				songAlbum.Album.Playtime = Utility.ConvertToPlaytime(songAlbum.Album.PlaytimeInSeconds);
				songAlbum.Album.ModifiedAt = DateTime.UtcNow;
				songAlbum.Album.ModifiedBy = _authService.GetUserName();
			}

			foreach (SongPlaylist songPlaylist in song.SongPlaylists)
			{
				songPlaylist.Playlist.PlaytimeInSeconds -= songOldPlaytimeInSeconds;
				songPlaylist.Playlist.PlaytimeInSeconds += song.PlaytimeInSeconds;
				songPlaylist.Playlist.Playtime = Utility.ConvertToPlaytime(songPlaylist.Playlist.PlaytimeInSeconds);
				songPlaylist.Playlist.ModifiedAt = DateTime.UtcNow;
			}

			song.ModifiedAt = DateTime.UtcNow;
			song.ModifiedBy = _authService.GetUserName();

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Audio set successfully" };
		}

		public async Task<MessageResponse?> SetImage(int id, ImageFileRequest request)
		{
			Song? song = await _context.Songs.FindAsync(id);

			if (song is null)
			{
				return null;
			}

			string defaultImageUrl = await _fileService.GetDefaultImageUrl();

			if (request.ImageFile is not null)
			{
				song.ImageUrl = await _fileService.UploadImage(id, "Song", request.ImageFile);
			}
			else
			{

				if (song.ImageUrl is not null && song.ImageUrl != defaultImageUrl && song.ImageUrl.Contains("song"))
				{
					await _fileService.DeleteImage(id, "Song");
				}

				song.ImageUrl = defaultImageUrl;
			}

			song.ModifiedAt = DateTime.UtcNow;
			song.ModifiedBy = _authService.GetUserName();

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Image set successfully" };
		}
	}
}
