namespace Melo.Models
{
	public class PagedResponse<TResponse>
	{
		public int Page {  get; set; }

		public int? PrevPage { get; set; }

		public int? NextPage { get; set; }

		public int TotalPages { get; set; }

		public int TotalItems { get; set; }

		public int Items {  get; set; }

		public List<TResponse> Data { get; set; } = new List<TResponse>();
	}
}
