using Microsoft.AspNetCore.Http;

namespace Melo.Services.Interfaces
{
	public interface IFileService
	{
		Task<string> UploadAudio(int entityId, IFormFile imageFile);
		Task DeleteAudio(int entityId);
		Task<string> UploadImage(int entityId, string entityType, IFormFile imageFile);
		Task DeleteImage(int entityId, string entityType);
	}
}
