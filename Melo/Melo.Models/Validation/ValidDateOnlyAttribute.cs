using System.ComponentModel.DataAnnotations;

namespace Melo.Models.Validation
{
	public class ValidDateOnlyAttribute : ValidationAttribute
	{
		public override bool IsValid(object? value)
		{
			var dateString = value as string;

			if (dateString is null || DateOnly.TryParse(dateString, out _))
			{
				return true;
			}

			return false;
		}
	}
}
