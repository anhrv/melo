using System.Collections;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models.Validation
{
	public class NoDuplicatesAttribute : ValidationAttribute
	{
		public override bool IsValid(object? value)
		{
			var list = value as IEnumerable;

			if (list != null)
			{
				var hashSet = new HashSet<object>();

				foreach (var item in list)
				{
					if (!hashSet.Add(item))
					{
						return false;
					}
				}
			}

			return true;
		}
	}
}
