using Melo.Models.Validation;
using Microsoft.AspNetCore.Http;

namespace Melo.Models
{
	public class ImageFileRequest
	{
		[ValidImage(ErrorMessage = "Image file is not valid")]
        public IFormFile? ImageFile { get; set; }
    }
}
