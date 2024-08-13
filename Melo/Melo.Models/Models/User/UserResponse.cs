namespace Melo.Models
{
	public class UserResponse
	{
		public int Id { get; set; }

		public DateTime? CreatedAt { get; set; }

		public string? CreatedBy { get; set; }

		public DateTime? ModifiedAt { get; set; }

		public string? ModifiedBy { get; set; }

		public string? FirstName { get; set; }

		public string? LastName { get; set; }

		public string? UserName { get; set; }

		public string? Email { get; set; }

		public string? Phone { get; set; }

		public bool? Subscribed { get; set; }

		public DateTime? SubscriptionStart { get; set; }

		public DateTime? SubscriptionEnd { get; set; }

		public bool? Deleted { get; set; }

		public List<RoleResponse> Roles { get; set; } = new List<RoleResponse>();
	}
}
