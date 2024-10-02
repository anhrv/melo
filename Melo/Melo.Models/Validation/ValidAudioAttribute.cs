using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models.Validation
{
	public class ValidAudioAttribute : ValidationAttribute
	{
		public override bool IsValid(object? value)
		{
			var audioFile = value as IFormFile;

			if (audioFile is null || audioFile.Length == 0 || !audioFile.ContentType.Equals("audio/mpeg", StringComparison.OrdinalIgnoreCase))
			{
				return false;
			}

			return true;
		}
	}
}
