using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Helpers;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking.Internal;

namespace Melo.Services
{
	public class PlaylistService : CRUDService<Playlist, PlaylistResponse, PlaylistSearch, PlaylistUpsert, PlaylistUpsert>, IPlaylistService
	{
		public PlaylistService(ApplicationDbContext context, IMapper mapper, IAuthService authService)
		: base(context, mapper, authService)
		{

		}

		public override async Task<PlaylistResponse?> GetById(int id)
		{
			Playlist? playlist = await _context.Playlists
												.Include(p => p.SongPlaylists)
													.ThenInclude(sp => sp.Song)
													.ThenInclude(s => s.SongGenres)
													.ThenInclude(sg => sg.Genre)
												.Include(p => p.SongPlaylists)
													.ThenInclude(sp => sp.Song)
													.ThenInclude(s => s.SongArtists)
													.ThenInclude(sa => sa.Artist)
												.FirstOrDefaultAsync(p => p.Id == id && p.UserId == _authService.GetUserId());

			if (playlist is null)
			{
				return null;
			}

			return _mapper.Map<PlaylistResponse>(playlist);
		}

		public override IQueryable<Playlist> AddFilters(PlaylistSearch request, IQueryable<Playlist> query)
		{
			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(p => p.Name.Contains(request.Name));
			}

			query = query.Where(p => p.UserId == _authService.GetUserId());

			return query;
		}

		public override async Task BeforeInsert(PlaylistUpsert request, Playlist entity)
		{
			entity.CreatedAt = DateTime.UtcNow;
			entity.UserId = _authService.GetUserId();
			entity.SongCount = 0;
			entity.Playtime = "0:00";
			entity.PlaytimeInSeconds = 0;
		}

		public override async Task<PlaylistResponse?> Update(int id, PlaylistUpsert request)
		{
			Playlist? entity = await _context.Playlists.FirstOrDefaultAsync(p => p.Id == id && p.UserId == _authService.GetUserId());

			if (entity is null)
			{
				return null;
			}

			_mapper.Map(request, entity);

			entity.ModifiedAt = DateTime.UtcNow;

			await _context.SaveChangesAsync();
			
			return _mapper.Map<PlaylistResponse>(entity);
		}

		public override async Task<PlaylistResponse?> Delete(int id)
		{
			Playlist? entity = await _context.Playlists.FirstOrDefaultAsync(p => p.Id == id && p.UserId == _authService.GetUserId());

			if (entity is null)
			{
				return null;
			}

			await BeforeDelete(entity);

			_context.Playlists.Remove(entity);

			await _context.SaveChangesAsync();
			
			return _mapper.Map<PlaylistResponse>(entity);
		}

		public async override Task BeforeDelete(Playlist entity)
		{
			using var transaction = await _context.Database.BeginTransactionAsync();

			try
			{
				var songPlaylists = _context.SongPlaylists.Where(sp => sp.PlaylistId == entity.Id);
				_context.SongPlaylists.RemoveRange(songPlaylists);

				await _context.SaveChangesAsync();

				await transaction.CommitAsync();
			}
			catch (Exception)
			{
				await transaction.RollbackAsync();
				throw;
			}
		}

		public async Task<MessageResponse?> RemoveSongs(int id, RemoveSongsRequest request)
		{
			Playlist? playlist = await _context.Playlists
												.Include(p => p.SongPlaylists)
													.ThenInclude(sp => sp.Song)
												.FirstOrDefaultAsync(p => p.Id == id && p.UserId == _authService.GetUserId());

			if (playlist is null)
			{
				return null;
			}

			List<SongPlaylist> validSongs = playlist.SongPlaylists.Where(sp => request.SongIds.Contains(sp.SongId)).ToList();

			if (validSongs.Count != request.SongIds.Count)
			{
				return new MessageResponse() { Success = false, Message = "Invalid songs provided" };
			}

			foreach (SongPlaylist songPlaylist in validSongs)
			{
				_context.SongPlaylists.Remove(songPlaylist);

				await _context.SongPlaylists
								.Where(sp => sp.PlaylistId == playlist.Id && sp.SongOrder > songPlaylist.SongOrder)
								.ExecuteUpdateAsync(sp => sp.SetProperty(sp => sp.SongOrder, sp => sp.SongOrder - 1)
															.SetProperty(sp => sp.ModifiedAt, sp => DateTime.UtcNow));

				playlist.PlaytimeInSeconds -= songPlaylist.Song.PlaytimeInSeconds;
				playlist.SongCount--;
			}

			playlist.Playtime = Utility.ConvertToPlaytime(playlist.PlaytimeInSeconds);
			playlist.ModifiedAt = DateTime.UtcNow;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Songs removed from playlist" };
		}


		public async Task<MessageResponse?> ReorderSongs(int id, ReorderSongsRequest request)
		{
			Playlist? playlist = await _context.Playlists
												.Include(p => p.SongPlaylists)
												.FirstOrDefaultAsync(p => p.Id == id && p.UserId == _authService.GetUserId());

			if (playlist is null)
			{
				return null;
			}

			List<int> currentSongIds = playlist.SongPlaylists.Select(sp => sp.SongId).ToList();

			if (!request.SongIds.All(currentSongIds.Contains) || currentSongIds.Count != request.SongIds.Count)
			{
				return new MessageResponse() { Success = false, Message = "Invalid songs provided" };
			}

			for (int i = 0; i < request.SongIds.Count; i++)
			{
				SongPlaylist songPlaylist = playlist.SongPlaylists.First(sp => sp.SongId == request.SongIds[i]);
				songPlaylist.SongOrder = i + 1;
				songPlaylist.ModifiedAt = DateTime.UtcNow;
			}

			playlist.ModifiedAt = DateTime.UtcNow;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Playlist reordered" };
		}
	}
}
