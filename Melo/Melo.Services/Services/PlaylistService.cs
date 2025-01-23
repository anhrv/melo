using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Helpers;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.ChangeTracking.Internal;
using System.Linq.Dynamic.Core;

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
			int userId = _authService.GetUserId();

			Playlist? playlist = await _context.Playlists.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId);

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

			int userId = _authService.GetUserId();

			query = query.Where(p => p.UserId == userId);

			return query;
		}

		public override IQueryable<Playlist> AddLovFilters(LovSearch request, IQueryable<Playlist> query)
		{
			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(p => p.Name.Contains(request.Name));
			}

			int userId = _authService.GetUserId();

			query = query.Where(p => p.UserId == userId);

			return query;
		}

		public override async Task BeforeInsert(PlaylistUpsert request, Playlist entity)
		{
			int userId = _authService.GetUserId();

			entity.CreatedAt = DateTime.UtcNow;
			entity.UserId = userId;
			entity.SongCount = 0;
			entity.Playtime = "0:00";
			entity.PlaytimeInSeconds = 0;
		}

		public override async Task<PlaylistResponse?> Update(int id, PlaylistUpsert request)
		{
			int userId = _authService.GetUserId();

			Playlist? entity = await _context.Playlists.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId);

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
			int userId = _authService.GetUserId();

			Playlist? entity = await _context.Playlists.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId);

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

		public async Task<PagedResponse<PlaylistSongResponse>?> GetPlaylistSongs(int id, SongSearch request)
		{
			int userId = _authService.GetUserId();

			Playlist? playlist = await _context.Playlists.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId);

			if (playlist is null)
			{
				return null;
			}

			int page = request.Page ?? 1;
			int pageSize = request.PageSize ?? 20;

			IQueryable<SongPlaylist> query = _context.SongPlaylists.AsQueryable();

			query = query.Include(sp => sp.Song)
						   .ThenInclude(s => s.SongGenres)
							 .ThenInclude(sg => sg.Genre)
						 .Include(sp => sp.Song)
						   .ThenInclude(s => s.SongArtists)
							 .ThenInclude(sa => sa.Artist)
						 .Where(sp => sp.Playlist.Id == id);

			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(sp => sp.Song.Name.Contains(request.Name));
			}

			if (request.GenreIds is not null && request.GenreIds.Count > 0)
			{
				query = query.Where(sp => request.GenreIds.All(gid => sp.Song.SongGenres.Any(sg => sg.GenreId == gid)));
			}

			if (request.ArtistIds is not null && request.ArtistIds.Count > 0)
			{
				query = query.Where(sp => request.ArtistIds.All(aid => sp.Song.SongArtists.Any(sa => sa.ArtistId == aid)));
			}

			var sortingOrder = request.Ascending.HasValue && request.Ascending.Value == true ? "ascending" : "descending";
			var sortBy = string.IsNullOrEmpty(request.SortBy) ? "SongOrder" : request.SortBy;

			query = query.OrderBy($"{sortBy} {sortingOrder}");

			int totalItems = await query.CountAsync();
			int totalPages = totalItems > 0 ? (int)Math.Ceiling(totalItems / (double)pageSize) : 1;

			page = page > totalPages ? totalPages : page;

			query = query.Skip((page - 1) * pageSize).Take(pageSize);

			List<SongPlaylist> list = await query.ToListAsync();

			List<PlaylistSongResponse> data = _mapper.Map<List<PlaylistSongResponse>>(list);

			PagedResponse<PlaylistSongResponse> pagedResponse = new PagedResponse<PlaylistSongResponse>
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

		public async Task<MessageResponse?> RemoveSongs(int id, RemoveSongsRequest request)
		{
			int userId = _authService.GetUserId();

			Playlist? playlist = await _context.Playlists
												.Include(p => p.SongPlaylists)
													.ThenInclude(sp => sp.Song)
												.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId);

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
			int userId = _authService.GetUserId();

			Playlist? playlist = await _context.Playlists
												.Include(p => p.SongPlaylists)
												.FirstOrDefaultAsync(p => p.Id == id && p.UserId == userId);

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
				songPlaylist.SongOrder = request.SongIds.Count - i;
				songPlaylist.ModifiedAt = DateTime.UtcNow;
			}

			playlist.ModifiedAt = DateTime.UtcNow;

			await _context.SaveChangesAsync();

			return new MessageResponse() { Success = true, Message = "Playlist reordered" };
		}
	}
}
