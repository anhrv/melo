using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	public class RecommendationsController : CustomControllerBase
	{
		private readonly ILogger<RecommendationsController> _logger;
		private readonly IRecommendationService _recommendationService;
		private readonly IModelTrainingService _modelTrainingService;

		public RecommendationsController(ILogger<RecommendationsController> logger, IRecommendationService recommendationService, IModelTrainingService modelTrainingService)
		{
			_logger = logger;
			_recommendationService = recommendationService;
			_modelTrainingService = modelTrainingService;
		}

		[Authorize(Policy = "SubscribedUser")]
		[HttpGet("Get-Recommendations")]
		public async Task<IActionResult> GetRecommendations([FromQuery] int size = 20)
		{
			var userHasSongInteractions = await _recommendationService.UserHasSongInteractions();
			var songRecommendations = !userHasSongInteractions ? await _recommendationService.GetPopularSongs(size) : await _recommendationService.GetSongRecommendations(size);

			var userHasArtistInteractions = await _recommendationService.UserHasArtistInteractions();
			var artistRecommendations = !userHasArtistInteractions ? await _recommendationService.GetPopularArtists(size) : await _recommendationService.GetArtistRecommendations(size);

			var userHasAlbumInteractions = await _recommendationService.UserHasAlbumInteractions();
			var albumRecommendations = !userHasAlbumInteractions ? await _recommendationService.GetPopularAlbums(size) : await _recommendationService.GetAlbumRecommendations(size);

			return Ok(new
			{
				Songs = songRecommendations,
				Artists = artistRecommendations,
				Albums = albumRecommendations
			});
		}

		[Authorize(Policy = "Admin")]
		[HttpPost("Train-Models")]
		public async Task<IActionResult> TrainModels()
		{
			try
			{
				await _modelTrainingService.TrainAndSaveModel("song");
				await _modelTrainingService.TrainAndSaveModel("artist");
				await _modelTrainingService.TrainAndSaveModel("album");
				_logger.LogInformation($"Models for recommender system trained at {DateTime.Now} (manual)");
				return Ok(new MessageResponse() { Success = true, Message = "Models trained and saved successfully." });
			}
			catch (Exception ex)
			{
				_logger.LogError(ex, "Error training models manually");
				return StatusCode(500, new MessageResponse() { Success = false, Message = "Not enough data for model training." });
			}
		}
	}
}
