using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class PlaylistService : CRUDService<Playlist, PlaylistResponse, PlaylistSearchObject, PlaylistUpsert, PlaylistUpsert>, IPlaylistService
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

			return _mapper.Map<PlaylistResponse>(playlist);
		}
		public override IQueryable<Playlist> AddFilters(PlaylistSearchObject request, IQueryable<Playlist> query)
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

			if (entity is not null)
			{
				_mapper.Map(request, entity);

				entity.ModifiedAt = DateTime.UtcNow;

				await _context.SaveChangesAsync();
			}

			return _mapper.Map<PlaylistResponse>(entity);
		
		}

		public override async Task<PlaylistResponse?> Delete(int id)
		{
			Playlist? entity = await _context.Playlists.FirstOrDefaultAsync(p => p.Id == id && p.UserId == _authService.GetUserId());

			if (entity is not null)
			{
				await BeforeDelete(entity);

				_context.Playlists.Remove(entity);
				await _context.SaveChangesAsync();
			}

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
	}
}
