using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using System.Net.Http.Headers;
using System.Net.Http.Json;

namespace Melo.Services
{
	public class FileService : IFileService
	{
		private readonly HttpClient _httpClient;

        public FileService(HttpClient httpClient)
        {
            _httpClient = httpClient;
        }

		public async Task<string> GetDefaultImageUrl()
		{
			string defaultImageUrl = $"image/url/default";

			HttpResponseMessage defaultImageUrlResponse = await _httpClient.GetAsync(defaultImageUrl);
			if (!defaultImageUrlResponse.IsSuccessStatusCode)
			{
				throw new Exception("Error getting default image");
			}
			FileUrlResponse? defaultImage = await defaultImageUrlResponse.Content.ReadFromJsonAsync<FileUrlResponse>();
			if (defaultImage is null)
			{
				throw new Exception("Error getting default image");
			}

			return defaultImage.Url;
		}

        public async Task<string> UploadImage(int entityId, string entityType, IFormFile imageFile)
        {
			using MultipartFormDataContent imageFormContent = new MultipartFormDataContent();
			using Stream imageStream = imageFile.OpenReadStream();

			StreamContent imageStreamContent = new StreamContent(imageStream);
			imageStreamContent.Headers.ContentType = new MediaTypeHeaderValue(imageFile.ContentType);

			imageFormContent.Add(imageStreamContent, "imageFile", imageFile.FileName);

			string uploadImageUrl = $"image/upload/{entityType}/{entityId}";
			HttpResponseMessage uploadImageResponse = await _httpClient.PostAsync(uploadImageUrl, imageFormContent);
			if (!uploadImageResponse.IsSuccessStatusCode)
			{
				throw new Exception("Error uploading image");
			}
			FileUrlResponse? uploadedImage = await uploadImageResponse.Content.ReadFromJsonAsync<FileUrlResponse>();
			if (uploadedImage is null)
			{
				throw new Exception("Error uploading image");
			}

			return uploadedImage.Url;
		}

		public async Task DeleteImage(int entityId, string entityType)
		{
			string deleteImageUrl = $"image/delete/{entityType}/{entityId}";
			HttpResponseMessage deleteImageResponse = await _httpClient.DeleteAsync(deleteImageUrl);
			if (!deleteImageResponse.IsSuccessStatusCode)
			{
				throw new Exception("Error deleting image");
			}
			MessageResponse? deletedImageMessage = await deleteImageResponse.Content.ReadFromJsonAsync<MessageResponse>();
			if (deletedImageMessage is null)
			{
				throw new Exception("Error deleting image");
			}
		}

	}
}
