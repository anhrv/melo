using Microsoft.AspNetCore.Http;

namespace Melo.Services.Interfaces
{
	public interface IFileService
	{
		Task<string> GetDefaultImageUrl();
		Task<string> UploadImage(int entityId, string entityType, IFormFile imageFile);
		Task DeleteImage(int entityId, string entityType);
	}
}
