using Melo.Models.Recommendations;
using Microsoft.EntityFrameworkCore;
using Microsoft.ML;

namespace Melo.Services.Recommendations
{
	public class ModelTrainingService
	{
		private readonly ApplicationDbContext _context;
		private readonly MLContext _mlContext;
		private readonly string _modelDirectory = Path.Combine(Directory.GetCurrentDirectory(), "Recommendations", "Models");

		public ModelTrainingService(ApplicationDbContext context)
		{
			_context = context;
			_mlContext = new MLContext();
		}

		public async Task TrainAndSaveModel(string entityType)
		{
			IEnumerable<RecommendationData> interactions = [];

			switch (entityType)
			{
				case "song":
					interactions = await GetUserSongInteractions();
					break;
				case "album":
					interactions = await GetUserAlbumInteractions();
					break;
				case "artist":
					interactions = await GetUserArtistInteractions();
					break;
				default:
					throw new Exception("Invalid entity type");
			}

			var model = TrainModel(interactions);
			SaveModel(model, $"{entityType}Model.zip");
		}

		private async Task<IEnumerable<RecommendationData>> GetUserSongInteractions()
		{
			var userSongInteractions = await _context.UserSongLikes.Select(ul => new RecommendationData
			{
				UserId = (uint)ul.UserId,
				EntityId = (uint)ul.SongId,
				InteractionScore = 2
			})
			.Union(_context.UserSongViews.Select(uv => new RecommendationData
			{
				UserId = (uint)uv.UserId,
				EntityId = (uint)uv.SongId,
				InteractionScore = (float)(0.1 * uv.Count)
			})
			).ToListAsync();

			return userSongInteractions;
		}

		private async Task<IEnumerable<RecommendationData>> GetUserArtistInteractions()
		{
			var userArtistInteractions = await _context.UserArtistLikes.Select(ul => new RecommendationData
			{
				UserId = (uint)ul.UserId,
				EntityId = (uint)ul.ArtistId,
				InteractionScore = 2
			})
			.Union(_context.UserArtistViews.Select(uv => new RecommendationData
			{
				UserId = (uint)uv.UserId,
				EntityId = (uint)uv.ArtistId,
				InteractionScore = (float)(0.1 * uv.Count)
			})
			).ToListAsync();

			return userArtistInteractions;
		}

		private async Task<IEnumerable<RecommendationData>> GetUserAlbumInteractions()
		{
			var userAlbumInteractions = await _context.UserAlbumLikes.Select(ul => new RecommendationData
			{
				UserId = (uint)ul.UserId,
				EntityId = (uint)ul.AlbumId,
				InteractionScore = 2
			})
			.Union(_context.UserAlbumViews.Select(uv => new RecommendationData
			{
				UserId = (uint)uv.UserId,
				EntityId = (uint)uv.AlbumId,
				InteractionScore = (float)(0.1 * uv.Count)
			})
			).ToListAsync();

			return userAlbumInteractions;
		}

		private ITransformer TrainModel(IEnumerable<RecommendationData> interactions)
		{
			var dataView = _mlContext.Data.LoadFromEnumerable(interactions);
			var pipeline = _mlContext.Recommendation().Trainers.MatrixFactorization(
				labelColumnName: "InteractionScore",
				matrixColumnIndexColumnName: "UserId",
				matrixRowIndexColumnName: "EntityId",
				numberOfIterations: 100,
				learningRate: 0.2f
			);
			return pipeline.Fit(dataView);
		}

		private void SaveModel(ITransformer model, string modelName)
		{
			var modelPath = Path.Combine(_modelDirectory, modelName);
			if (!Directory.Exists(_modelDirectory))
			{
				Directory.CreateDirectory(_modelDirectory);
			}
			_mlContext.Model.Save(model, null, modelPath);
		}
	}
}
