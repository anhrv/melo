namespace Melo.Models
{
	public class GenreResponse
	{ 
		public int Id { get; set; }

		public DateTime? CreatedAt { get; set; }

		public string? CreatedBy { get; set; }

		public DateTime? ModifiedAt { get; set; }

		public string? ModifiedBy { get; set; }

		public string? Name { get; set; }

		public long? ViewCount { get; set; }

		public string? ImageUrl { get; set; }
	}
}
