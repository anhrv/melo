using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class BaseSearch
	{
		[Range(1, int.MaxValue, ErrorMessage = "Minimum page value is 1")]
		public int? Page {  get; set; }

		[Range(1, int.MaxValue, ErrorMessage = "Minimum page size value is 1")]
		public int? PageSize { get; set; }

		public string? SortBy { get; set; }

		public bool? Ascending { get; set; }
	}
}
