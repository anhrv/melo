using Melo.Services.Interfaces;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;

namespace Melo.Services
{
    public class ModelTrainingBackgroundService : BackgroundService
    {
        private readonly IServiceProvider _serviceProvider;
        private readonly ILogger<ModelTrainingBackgroundService> _logger;

        public ModelTrainingBackgroundService(IServiceProvider serviceProvider, ILogger<ModelTrainingBackgroundService> logger)
        {
            _serviceProvider = serviceProvider;
            _logger = logger;
        }

        protected override async Task ExecuteAsync(CancellationToken stoppingToken)
        {
            await TrainModelsAsync(stoppingToken);

            while (!stoppingToken.IsCancellationRequested)
            {
                await Task.Delay(TimeSpan.FromHours(24), stoppingToken);

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
