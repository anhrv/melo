using Melo.Models.Validation;
using Microsoft.AspNetCore.Http;

namespace Melo.Models
{
	public class AudioFileRequest
	{
		[ValidAudio(ErrorMessage = "Audio file is not valid")]
        public IFormFile? AudioFile { get; set; }
    }
}
