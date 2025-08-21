namespace Melo.Models
{
	public class UserSearch : BaseSearch
	{
		public string? FirstName { get; set; }

		public string? LastName { get; set; }

		public string? UserName { get; set; }

		public string? Email { get; set; }

		public bool? Deleted { get; set; }

		public bool? Subscribed { get; set; }

		public List<int>? RoleIds { get; set; }
	}
}
