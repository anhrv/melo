using EasyNetQ;
using Melo.Files.Helpers;
using Melo.Models;
using Melo.Models.View;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Extensions.Caching.Memory;

namespace Melo.Files.Controllers
{
	public class AudioController : CustomControllerBase
    {
		private readonly ILogger<AudioController> _logger;
		private readonly IMemoryCache _cache;
		private readonly IConfiguration _configuration;

		public AudioController(IWebHostEnvironment env, ILogger<AudioController> logger, IMemoryCache cache, IConfiguration configuration) : base(env)
        {
			_logger = logger;
			_cache = cache;
			_configuration = configuration;
        }

		[HttpGet("Stream/{entityId}")]
		public async Task<IActionResult> Stream([FromRoute] int entityId)
		{
			string audioPath = Path.Combine(_env.ContentRootPath, "Files", "Audio", $"{entityId}.mp3");

			if (!System.IO.File.Exists(audioPath))
			{
				return NotFound(ErrorResponse.NotFound("Audio file does not exist"));
			}

			var userId = GetUserIdFromJwt();
			if (string.IsNullOrEmpty(userId))
			{
				return Unauthorized(ErrorResponse.Unauthorized("Invalid or missing JWT token"));
			}

			if (User.IsInRole("User"))
			{
				string sessionKey = $"stream_{userId}_{entityId}";

				if (_cache.TryGetValue<DateTime>(sessionKey, out var lastStreamTime))
				{
					if (DateTime.UtcNow < lastStreamTime.AddMinutes(5))
					{
						return ProceedWithStreaming(audioPath);
					}
				}

				IBus bus = RabbitHutch.CreateBus(_configuration["RabbitMQ:Host"]);
				await bus.PubSub.PublishAsync(new ViewRequest() { UserId = int.Parse(userId), SongId = entityId });

				_cache.Set(sessionKey, DateTime.UtcNow, TimeSpan.FromHours(1));
			}

			return ProceedWithStreaming(audioPath);
		}

		private IActionResult ProceedWithStreaming(string audioPath)
		{
			FileInfo fileInfo = new FileInfo(audioPath);
			long fileSize = fileInfo.Length;
			FileStream fileStream = new FileStream(audioPath, FileMode.Open, FileAccess.Read, FileShare.Read, bufferSize: 4096, useAsync: true);

			if (!Request.Headers.ContainsKey("Range"))
			{
				return new FileStreamResult(fileStream, "audio/mpeg") { EnableRangeProcessing = true };
			}

			string rangeHeader = Request.Headers["Range"].ToString();
			string[] range = rangeHeader.Replace("bytes=", "").Split('-');
			long startByte = long.Parse(range[0]);
			long endByte = range.Length > 1 && !string.IsNullOrWhiteSpace(range[1]) ? long.Parse(range[1]) : fileSize - 1;

			if (startByte >= fileSize || endByte >= fileSize)
			{
				fileStream.Dispose();
				return StatusCode(416, ErrorResponse.RangeNotSatisfiable());
			}

			long contentLength = endByte - startByte + 1;

			Response.StatusCode = 206;
			Response.Headers.Append("Content-Range", $"bytes {startByte}-{endByte}/{fileSize}");
			Response.Headers.Append("Accept-Ranges", "bytes");
			Response.Headers.Append("Content-Length", contentLength.ToString());

			fileStream.Seek(startByte, SeekOrigin.Begin);

			return new FileStreamResult(fileStream, "audio/mpeg") { EnableRangeProcessing = true };
		}

		private string? GetUserIdFromJwt()
		{
			var userIdClaim = User.Claims.FirstOrDefault(c => c.Type == "sub");
			return userIdClaim?.Value;
		}

		[Authorize(Policy = "Admin")]
		[HttpPost("Upload/{entityId}")]
		public async Task<IActionResult> Upload([FromRoute] int entityId, [FromForm] IFormFile audioFile)
		{
			if (!Utility.ValidEntityId(entityId))
			{
				return BadRequest(ErrorResponse.BadRequest("Invalid entity ID"));
			}

			if (audioFile == null || audioFile.Length == 0)
			{
				return BadRequest(ErrorResponse.BadRequest("No audio file provided"));
			}

			if (!audioFile.ContentType.Equals("audio/mpeg", StringComparison.OrdinalIgnoreCase))
			{
				return BadRequest(ErrorResponse.BadRequest("Only MP3 is allowed"));
			}

			string audioFolder = Path.Combine(_env.ContentRootPath, "Files", "Audio");
			Directory.CreateDirectory(audioFolder);
			string audioPath = Path.Combine(audioFolder, $"{entityId}.mp3");

			try
			{
				using FileStream stream = new FileStream(audioPath, FileMode.Create, FileAccess.Write, FileShare.None, 4096, useAsync: true);
				await audioFile.CopyToAsync(stream);
				
				string audioUrl = $"{Request.Scheme}://{Request.Host}/api/audio/stream/{entityId}";

				return Ok(new FileUrlResponse { Url = audioUrl });
			}
			catch(Exception exception)
			{
				_logger.LogError(exception, exception.Message);
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
		}

		[Authorize(Policy = "Admin")]
		[HttpDelete("Delete/{entityId}")]
		public async Task<IActionResult> Delete([FromRoute] int entityId)
		{
			string audioPath = Path.Combine(_env.ContentRootPath, "Files", "Audio", $"{entityId}.mp3");

			if (!System.IO.File.Exists(audioPath))
			{
				return NotFound(ErrorResponse.NotFound("Audio file does not exist"));
			}

			try
			{
				await Task.Run(() => System.IO.File.Delete(audioPath));

				return Ok(new MessageResponse { Success = true, Message = "Audio file deleted successfully" });
			}
			catch(Exception exception)
			{
				_logger.LogError(exception, exception.Message);
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
		}
	}
}
