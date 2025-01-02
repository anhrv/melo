using Melo.Services.Interfaces;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Melo.Services
{
    public class ModelTrainingBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<ModelTrainingBackgroundService> _logger;
        private readonly IConfiguration _configuration;

        public ModelTrainingBackgroundService(IServiceProvider serviceProvider, ILogger<ModelTrainingBackgroundService> logger, IConfiguration configuration)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
            _configuration = configuration;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await TrainModelsAsync(stoppingToken);

            string modelTrainingFrequencyHours = Environment.GetEnvironmentVariable("RECOMMENDER_MODEL_TRAINING_FREQUENCY_HOURS") ?? _configuration["Recommender:ModelTrainingFrequencyHours"];

			while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromHours(Convert.ToDouble(modelTrainingFrequencyHours)), stoppingToken);

                await TrainModelsAsync(stoppingToken);
            }
        }

        private async Task TrainModelsAsync(CancellationToken cancellationToken)
        {
            using var scope = _serviceProvider.CreateScope();
            var modelTrainingService = scope.ServiceProvider.GetRequiredService<IModelTrainingService>();

            await modelTrainingService.TrainAndSaveModel("song");
            await modelTrainingService.TrainAndSaveModel("artist");
            await modelTrainingService.TrainAndSaveModel("album");

            _logger.LogInformation($"Models for recommender system trained at {DateTime.Now} (scheduled)");
        }
    }
}
