using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
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

		public async Task<string> UploadAudio(int entityId, IFormFile audioFile)
		{
			using MultipartFormDataContent audioFormContent = new MultipartFormDataContent();
			using Stream audioStream = audioFile.OpenReadStream();

			StreamContent audioStreamContent = new StreamContent(audioStream);
			audioStreamContent.Headers.ContentType = new MediaTypeHeaderValue(audioFile.ContentType);

			audioFormContent.Add(audioStreamContent, "audioFile", audioFile.FileName);

			string uploadAudioUrl = $"audio/upload/{entityId}";
			HttpResponseMessage uploadAudioResponse = await _httpClient.PostAsync(uploadAudioUrl, audioFormContent);
			if (!uploadAudioResponse.IsSuccessStatusCode)
			{
				throw new Exception("Error uploading audio");
			}
			FileUrlResponse? uploadedAudio = await uploadAudioResponse.Content.ReadFromJsonAsync<FileUrlResponse>();
			if (uploadedAudio is null)
			{
				throw new Exception("Error uploading audio");
			}

			return uploadedAudio.Url;
		}

		public async Task DeleteAudio(int entityId)
		{
			string deleteAudioUrl = $"audio/delete/{entityId}";
			HttpResponseMessage deleteAudioResponse = await _httpClient.DeleteAsync(deleteAudioUrl);
			if (!deleteAudioResponse.IsSuccessStatusCode)
			{
				throw new Exception("Error deleting audio");
			}
			MessageResponse? deletedAudioMessage = await deleteAudioResponse.Content.ReadFromJsonAsync<MessageResponse>();
			if (deletedAudioMessage is null)
			{
				throw new Exception("Error deleting audio");
			}
		}

		public async Task<string> GetDefaultImageUrl()
		{
			string defaultImageUrl = "image/url/default";

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
