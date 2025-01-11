using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services
{
	public class RoleService : IRoleService
	{
		private readonly ApplicationDbContext _context;
		private readonly IMapper _mapper;

		public RoleService(ApplicationDbContext context, IMapper mapper)
		{
			_context = context;
			_mapper = mapper;
		}

		public async Task<List<LovResponse>> GetLov()
		{
			List<Role> data = await _context.Roles.ToListAsync();

			return _mapper.Map<List<LovResponse>>(data);
		}
	}
}
