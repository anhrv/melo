using Melo.Files.Models;
using Melo.Models;
using Microsoft.AspNetCore.Mvc;

namespace Melo.Files.Controllers
{
	public class AudioController : CustomControllerBase
    {
		private readonly ILogger<AudioController> _logger;

		public AudioController(IWebHostEnvironment env, ILogger<AudioController> logger) : base(env)
        {
			_logger = logger;
        }

		[HttpGet("Stream/{entityId}")]
		public async Task<IActionResult> Stream([FromRoute] int entityId)
		{
			string audioPath = Path.Combine(_env.ContentRootPath, "Files", "Audio", $"{entityId}.mp3");

			if (!System.IO.File.Exists(audioPath))
			{
				return NotFound(ErrorResponse.NotFound("Audio file does not exist"));
			}

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

		[HttpPost("Upload/{entityId}")]
		public async Task<IActionResult> Upload([FromRoute] int entityId, [FromForm] FileUploadRequest request)
		{
			if (!ValidEntityId(entityId))
			{
				return BadRequest(ErrorResponse.BadRequest("Invalid entity ID"));
			}

			if (request.File == null || request.File.Length == 0)
			{
				return BadRequest(ErrorResponse.BadRequest("No audio file provided"));
			}

			if (!request.File.ContentType.Equals("audio/mpeg", StringComparison.OrdinalIgnoreCase))
			{
				return BadRequest(ErrorResponse.BadRequest("Only MP3 is allowed"));
			}

			string audioFolder = Path.Combine(_env.ContentRootPath, "Files", "Audio");
			Directory.CreateDirectory(audioFolder);
			string audioPath = Path.Combine(audioFolder, $"{entityId}.mp3");

			try
			{
				using FileStream stream = new FileStream(audioPath, FileMode.Create, FileAccess.Write, FileShare.None, 4096, useAsync: true);
				await request.File.CopyToAsync(stream);
				
				string audioUrl = $"{Request.Scheme}://{Request.Host}/api/audio/stream/{entityId}";

				return Ok(new FileUploadResponse { Url = audioUrl });
			}
			catch(Exception exception)
			{
				_logger.LogError(exception, exception.Message);
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
		}

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

		private bool ValidEntityId(int id)
		{
			return id > 0;
		}
	}
}
