using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class RoleService : IRoleService
	{
		private readonly ApplicationDbContext _context;

		public RoleService(ApplicationDbContext context)
		{
			_context = context;
		}

		public async Task<int> GetRoleIdByName(string name)
		{
			int roleId = await _context.Roles.Where(r => r.Name == name).Select(r => r.Id).FirstOrDefaultAsync();

			if (roleId == default)
			{
				throw new Exception($"Role '{name}' not found.");
			}

			return roleId;
		}
	}
}
