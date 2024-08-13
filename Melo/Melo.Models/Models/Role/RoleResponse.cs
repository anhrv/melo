namespace Melo.Models
{
	public class RoleResponse
	{
		public int Id { get; set; }

		public DateTime? CreatedAt { get; set; }

		public string? CreatedBy { get; set; }

		public DateTime? ModifiedAt { get; set; }

		public string? ModifiedBy { get; set; }

		public string? Name { get; set; }
	}
}
