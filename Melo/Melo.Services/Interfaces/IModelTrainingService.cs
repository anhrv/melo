namespace Melo.Services.Interfaces
{
	public interface IModelTrainingService
	{
		Task TrainAndSaveModel(string entityType);
	}
}
