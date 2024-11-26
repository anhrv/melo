using MapsterMapper;
using Melo.Models;
using Melo.Models.Recommendations;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;

namespace Melo.Services.Recommendations
{
    public class RecommendationService
	{
		private readonly string _modelDirectory = Path.Combine(Directory.GetCurrentDirectory(), "Recommendations", "Models");

		private readonly ApplicationDbContext _context;
		private readonly MLContext _mlContext;
		private readonly IAuthService _authService;
		private readonly IMapper _mapper;

		private ITransformer _cachedSongModel;
		private ITransformer _cachedArtistModel;
		private ITransformer _cachedAlbumModel;

		public RecommendationService(ApplicationDbContext context, IAuthService authService, IMapper mapper)
		{
			_context = context;
			_mlContext = new MLContext();
			_authService = authService;
			_mapper = mapper;
		}

		public ITransformer LoadSongModel()
		{
			if (_cachedSongModel == null)
			{
				var modelPath = Path.Combine(_modelDirectory, "songModel.zip");
				if (File.Exists(modelPath))
				{
					_cachedSongModel = _mlContext.Model.Load(modelPath, out var modelInputSchema);
				}
			}
			return _cachedSongModel;
		}

		public ITransformer LoadArtistModel()
		{
			if (_cachedArtistModel == null)
			{
				var modelPath = Path.Combine(_modelDirectory, "artistModel.zip");
				if (File.Exists(modelPath))
				{
					_cachedArtistModel = _mlContext.Model.Load(modelPath, out var modelInputSchema);
				}
			}
			return _cachedArtistModel;
		}

		public ITransformer LoadAlbumModel()
		{
			if (_cachedAlbumModel == null)
			{
				var modelPath = Path.Combine(_modelDirectory, "albumModel.zip");
				if (File.Exists(modelPath))
				{
					_cachedAlbumModel = _mlContext.Model.Load(modelPath, out var modelInputSchema);
				}
			}
			return _cachedAlbumModel;
		}

		public async Task<List<SongResponse>> GetSongRecommendations(int size)
		{
			var userId = _authService.GetUserId();
			var model = LoadSongModel();
			return await GetRecommendations<Song, SongResponse>(userId, size, model, "song");
		}

		public async Task<List<ArtistResponse>> GetArtistRecommendations(int size)
		{
			var userId = _authService.GetUserId();
			var model = LoadArtistModel();
			return await GetRecommendations<Artist, ArtistResponse>(userId, size, model, "artist");
		}

		public async Task<List<AlbumResponse>> GetAlbumRecommendations(int size)
		{
			var userId = _authService.GetUserId();
			var model = LoadAlbumModel();
			return await GetRecommendations<Album, AlbumResponse>(userId, size, model, "album");
		}

		private async Task<List<TResponse>> GetRecommendations<TEntity, TResponse>(int userId, int size, ITransformer model, string entityType)
		{
			var predictionEngine = _mlContext.Model.CreatePredictionEngine<RecommendationData, Prediction>(model);

			var allEntities = await GetAllEntities<TEntity, TResponse>(entityType);

			var predictions = new List<(TResponse entity, float score)>();

			foreach (var entity in allEntities)
			{
				var prediction = predictionEngine.Predict(new RecommendationData
				{
					UserId = (uint)userId,
					EntityId = GetEntityId(entity)
				});

				predictions.Add((entity, prediction.Score));
			}

			var topPredictions = predictions
				.OrderByDescending(p => p.score)
				.Take(size)
				.Select(p => p.entity)
				.ToList();

			return topPredictions;
		}

		private async Task<List<TResponse>> GetAllEntities<TEntity, TResponse>(string entityType)
		{
			List<TEntity> entities = new List<TEntity>();

			switch (entityType)
			{
				case "song":
					entities = await _context.Songs.Include(s => s.SongGenres)
													 .ThenInclude(sg => sg.Genre)
												   .Include(s => s.SongArtists)
												     .ThenInclude(sa => sa.Artist)
												   .Cast<TEntity>().ToListAsync();
					break;
				case "artist":
					entities = await _context.Artists.Include(a => a.ArtistGenres)
						                               .ThenInclude(ag => ag.Genre)
													 .Cast<TEntity>().ToListAsync();
					break;
				case "album":
					entities = await _context.Albums.Include(a => a.AlbumGenres)
													  .ThenInclude(ag => ag.Genre)
													.Include(a => a.AlbumArtists)
													  .ThenInclude(aa => aa.Artist)
													.Cast<TEntity>().ToListAsync();
					break;
				default:
					throw new Exception("Invalid entity type");
			}

			return _mapper.Map<List<TResponse>>(entities);
		}

		private uint GetEntityId<T>(T entity)
		{
			if (entity is SongResponse song) return (uint)song.Id;
			if (entity is ArtistResponse artist) return (uint)artist.Id;
			if (entity is AlbumResponse album) return (uint)album.Id;
			throw new Exception("Entity does not have a valid ID");
		}

		public async Task<bool> UserHasSongInteractions()
		{
			var userId = _authService.GetUserId();
			var userSongLikes = await _context.UserSongLikes.Where(usl => usl.UserId == userId).ToListAsync();
			var userSongViews = await _context.UserSongViews.Where(usv => usv.UserId == userId).ToListAsync();

			return userSongLikes.Any() || userSongViews.Any();
		}

		public async Task<bool> UserHasArtistInteractions()
		{
			var userId = _authService.GetUserId();
			var userArtistLikes = await _context.UserArtistLikes.Where(ual => ual.UserId == userId).ToListAsync();
			var userArtistViews = await _context.UserArtistViews.Where(uav => uav.UserId == userId).ToListAsync();

			return userArtistLikes.Any() || userArtistViews.Any();
		}

		public async Task<bool> UserHasAlbumInteractions()
		{
			var userId = _authService.GetUserId();
			var userAlbumLikes = await _context.UserAlbumLikes.Where(ual => ual.UserId == userId).ToListAsync();
			var userAlbumViews = await _context.UserAlbumViews.Where(uav => uav.UserId == userId).ToListAsync();

			return userAlbumLikes.Any() || userAlbumViews.Any();
		}

		public async Task<List<SongResponse>> GetPopularSongs(int size)
		{
			var songs = await _context.Songs.Include(s => s.SongGenres)
											  .ThenInclude(sg => sg.Genre)
											.Include(s => s.SongArtists)
											  .ThenInclude(sa => sa.Artist)
											.OrderByDescending(s => s.LikeCount).Take(size).ToListAsync();
			return _mapper.Map<List<SongResponse>>(songs);
		}

		public async Task<List<ArtistResponse>> GetPopularArtists(int size)
		{
			var artists = await _context.Artists.Include(a => a.ArtistGenres)
												  .ThenInclude(ag => ag.Genre)
												.OrderByDescending(a => a.LikeCount).Take(size).ToListAsync();
			return _mapper.Map<List<ArtistResponse>>(artists);
		}

		public async Task<List<AlbumResponse>> GetPopularAlbums(int size)
		{
			var albums = await _context.Albums.Include(a => a.AlbumGenres)
											    .ThenInclude(ag => ag.Genre)
											  .Include(a => a.AlbumArtists)
											    .ThenInclude(aa => aa.Artist)
											  .OrderByDescending(a => a.LikeCount).Take(size).ToListAsync();
			return _mapper.Map<List<AlbumResponse>>(albums);
		}
	}
}
