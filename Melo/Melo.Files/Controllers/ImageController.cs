using Melo.Files.Helpers;
using Melo.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.Files.Controllers
{
	public class ImageController : CustomControllerBase
	{
		private readonly ILogger<ImageController> _logger;

		public ImageController(IWebHostEnvironment env, ILogger<ImageController> logger) : base(env)
		{
			_logger = logger;
		}

		[Authorize(Policy = "AdminOrSubscribedUser")]
		[HttpGet("Stream/{entityType}/{entityId}")]
		public async Task<IActionResult> Stream([FromRoute] string entityType, [FromRoute] int entityId)
		{
			string imagePath = Path.Combine(_env.ContentRootPath, "Files", "Image", entityType, $"{entityId}.jpg");

			if (!System.IO.File.Exists(imagePath))
			{
				return NotFound(ErrorResponse.NotFound("Image file does not exist"));
			}

			FileInfo fileInfo = new FileInfo(imagePath);
			long fileSize = fileInfo.Length;
			FileStream fileStream = new FileStream(imagePath, FileMode.Open, FileAccess.Read, FileShare.Read, bufferSize: 4096, useAsync: true);

			if (!Request.Headers.ContainsKey("Range"))
			{
				return new FileStreamResult(fileStream, "image/jpeg") { EnableRangeProcessing = true };
			}

			string rangeHeader = Request.Headers["Range"].ToString();
			string[] range = rangeHeader.Replace("bytes=", "").Split('-');
			long startByte = long.Parse(range[0]);
			long endByte = range.Length > 1 && !string.IsNullOrEmpty(range[1]) ? long.Parse(range[1]) : fileSize - 1;

			if (startByte >= fileSize || endByte >= fileSize)
			{
				fileStream.Dispose();
				return StatusCode(416, ErrorResponse.RangeNotSatisfiable());
			}

			var contentLength = endByte - startByte + 1;

			Response.StatusCode = 206;
			Response.Headers.Append("Content-Range", $"bytes {startByte}-{endByte}/{fileSize}");
			Response.Headers.Append("Accept-Ranges", "bytes");
			Response.Headers.Append("Content-Length", contentLength.ToString());

			fileStream.Seek(startByte, SeekOrigin.Begin);

			return new FileStreamResult(fileStream, "image/jpeg") { EnableRangeProcessing = true };
		}

		[Authorize(Policy = "Admin")]
		[HttpPost("Upload/{entityType}/{entityId}")]
		public async Task<IActionResult> Upload([FromRoute] string entityType, [FromRoute] int entityId, [FromForm] IFormFile imageFile)
		{
			if (!Utility.ValidEntityType(entityType))
			{
				return BadRequest(ErrorResponse.BadRequest("Invalid entity type"));
			}

			if (!Utility.ValidEntityId(entityId))
			{
				return BadRequest(ErrorResponse.BadRequest("Invalid entity ID"));
			}

			if (imageFile == null || imageFile.Length == 0)
			{
				return BadRequest(ErrorResponse.BadRequest("No image file provided"));
			}

			if (!imageFile.ContentType.Equals("image/jpeg", StringComparison.OrdinalIgnoreCase))
			{
				return BadRequest(ErrorResponse.BadRequest("Only JPG/JPEG is allowed"));
			}

			string imageFolder = Path.Combine(_env.ContentRootPath, "Files", "Image", Utility.CapitalizeFirstLetter(entityType));
			Directory.CreateDirectory(imageFolder);
			string imagePath = Path.Combine(imageFolder, $"{entityId}{Path.GetExtension(imageFile.FileName).ToLower()}");

			try
			{
				using FileStream stream = new FileStream(imagePath, FileMode.Create, FileAccess.Write, FileShare.None, 4096, useAsync: true);
				await imageFile.CopyToAsync(stream);

				string? publicHost = Environment.GetEnvironmentVariable("PUBLIC_HOST");
				string? publicPort = Environment.GetEnvironmentVariable("PUBLIC_PORT");
				string host = String.Empty;

				if (String.IsNullOrWhiteSpace(publicHost) || String.IsNullOrWhiteSpace(publicPort))
				{
					host = Request.Host.Value;
				}
				else
				{
					host = $"{publicHost}:{publicPort}";
				}

				string imageUrl = $"{Request.Scheme}://{host}/api/audio/stream/{entityId}";

				return Ok(new FileUrlResponse { Url = imageUrl });
			}
			catch (Exception exception)
			{
				_logger.LogError(exception, exception.Message);
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
		}

		[Authorize(Policy = "Admin")]
		[HttpDelete("Delete/{entityType}/{entityId}")]
		public async Task<IActionResult> Delete([FromRoute] string entityType, [FromRoute] int entityId)
		{
			string imagePath = Path.Combine(_env.ContentRootPath, "Files", "Image", entityType, $"{entityId}.jpg");

			if (!System.IO.File.Exists(imagePath))
			{
				return NotFound(ErrorResponse.NotFound("Image file does not exist"));
			}

			try
			{
				await Task.Run(() => System.IO.File.Delete(imagePath));

				return Ok(new MessageResponse { Success = true, Message = "Image file deleted successfully" });
			}
			catch (Exception exception)
			{
				_logger.LogError(exception, exception.Message);
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
		}
	}
}
