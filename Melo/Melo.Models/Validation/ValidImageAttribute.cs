using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models.Validation
{
	public class ValidImageAttribute : ValidationAttribute
	{
		public override bool IsValid(object? value)
		{
			var imageFile = value as IFormFile;

			if (imageFile is not null)
			{
				if (imageFile.Length == 0 || !imageFile.ContentType.Equals("image/jpeg", StringComparison.OrdinalIgnoreCase))
				{
					return false;
				}
			}

			return true;
		}
	}
}
