using MapsterMapper;
using Melo.Models;
using Melo.Services.Entities;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Data;
using System.Linq.Dynamic.Core;

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

		public async Task<PagedResponse<LovResponse>> GetLov(LovSearch request)
		{
			int page = request.Page ?? 1;
			int pageSize = request.PageSize ?? 20;

			IQueryable<Role> query = _context.Roles.AsQueryable();

			if (!string.IsNullOrWhiteSpace(request.Name))
			{
				query = query.Where(r => r.Name.Contains(request.Name));
			}

			var sortingOrder = request.Ascending.HasValue && request.Ascending.Value == true ? "ascending" : "descending";
			var sortBy = string.IsNullOrEmpty(request.SortBy) ? "CreatedAt" : request.SortBy;
			query = query.OrderBy($"{sortBy} {sortingOrder}");

			int totalItems = await query.CountAsync();
			int totalPages = totalItems > 0 ? (int)Math.Ceiling(totalItems / (double)pageSize) : 1;

			page = page > totalPages ? totalPages : page;

			query = query.Skip((page - 1) * pageSize).Take(pageSize);

			List<Role> list = await query.ToListAsync();

			List<LovResponse> data = _mapper.Map<List<LovResponse>>(list);

			PagedResponse<LovResponse> pagedResponse = new PagedResponse<LovResponse>
			{
				Data = data,
				Items = data.Count,
				TotalItems = totalItems,
				Page = page,
				PrevPage = page > 1 ? page - 1 : null,
				NextPage = page < totalPages ? page + 1 : null,
				TotalPages = totalPages
			};

			return pagedResponse;
		}
	}
}
