using Melo.Models;
using Melo.Services.Recommendations;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	public class RecommendationsController : CustomControllerBase
	{
		private readonly RecommendationService _recommendationService;
		private readonly ModelTrainingService _modelTrainingService;

		public RecommendationsController(RecommendationService recommendationService, ModelTrainingService modelTrainingService)
		{
			_recommendationService = recommendationService;
			_modelTrainingService = modelTrainingService;
		}

		[Authorize(Policy = "User")]
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
			await _modelTrainingService.TrainAndSaveModel("song");
			await _modelTrainingService.TrainAndSaveModel("artist");
			await _modelTrainingService.TrainAndSaveModel("album");
			return Ok(new MessageResponse() { Success = true, Message = "Models trained and saved successfully." });
		}
	}
}
