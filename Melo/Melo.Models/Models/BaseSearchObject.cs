namespace Melo.Models
{
	public class BaseSearchObject
	{
		public int? Page {  get; set; }
		public int? PageSize { get; set; }
		public string? SortBy { get; set; }
		public bool? Ascending { get; set; }
	}
}
