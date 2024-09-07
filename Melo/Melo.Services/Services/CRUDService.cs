using MapsterMapper;
using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace Melo.Services
{
	public class CRUDService<TEntity, TModel, TSearch, TCreate, TUpdate> : ICRUDService<TModel, TSearch, TCreate, TUpdate> where TEntity : class where TSearch : BaseSearch
	{
		protected readonly ApplicationDbContext _context;
		protected readonly IMapper _mapper;
		protected readonly IAuthService _authService;

		public CRUDService(ApplicationDbContext context, IMapper mapper, IAuthService authService)
		{
			_context = context;
			_mapper = mapper;
			_authService = authService;
		}

		public virtual async Task<PagedResponse<TModel>> GetPaged(TSearch request)
		{
			int page = request.Page ?? 1;
			int pageSize = request.PageSize ?? 20;

			IQueryable<TEntity> query = _context.Set<TEntity>().AsQueryable();

			query = AddFilters(request, query);

			if (!string.IsNullOrEmpty(request.SortBy))
			{
				var sortingOrder = request.Ascending.HasValue && request.Ascending.Value==true ? "ascending" : "descending";
				query = query.OrderBy($"{request.SortBy} {sortingOrder}");
			}

			int totalItems = await query.CountAsync();
			int totalPages = totalItems > 0 ? (int)Math.Ceiling(totalItems / (double)pageSize) : 1;

			page = page > totalPages ? totalPages : page;

			query = query.Skip((page-1) * pageSize).Take(pageSize);

			List<TEntity> list = await query.ToListAsync();

			List<TModel> data = _mapper.Map<List<TModel>>(list);

			PagedResponse<TModel> pagedResponse = new PagedResponse<TModel>
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

		public virtual IQueryable<TEntity> AddFilters(TSearch request, IQueryable<TEntity> query)
		{
			return query;
		}

		public virtual async Task<TModel?> GetById(int id)
		{ 
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			return _mapper.Map<TModel>(entity);
		}

		public virtual async Task<TModel> Create(TCreate request)
		{
			TEntity entity = _mapper.Map<TEntity>(request);

			await BeforeInsert(request, entity);

			await _context.Set<TEntity>().AddAsync(entity);

			await _context.SaveChangesAsync();

			await AfterInsert(request, entity);

			return _mapper.Map<TModel>(entity);
		}

		public virtual async Task BeforeInsert(TCreate request, TEntity entity)
		{

		}

		public virtual async Task AfterInsert(TCreate request, TEntity entity)
		{

		}

		public virtual async Task<TModel?> Update(int id, TUpdate request)
		{
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			if (entity is not null)
			{
				_mapper.Map(request, entity);

				await BeforeUpdate(request, entity);

				await _context.SaveChangesAsync();

				await AfterUpdate(request, entity);
			}

			return _mapper.Map<TModel>(entity);
		}

		public virtual async Task BeforeUpdate(TUpdate request, TEntity entity)
		{

		}

		public virtual async Task AfterUpdate(TUpdate request, TEntity entity)
		{

		}

		public virtual async Task<TModel?> Delete(int id)
		{
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			if (entity is not null)
			{
				await BeforeDelete(entity);

				_context.Set<TEntity>().Remove(entity);

				await _context.SaveChangesAsync();

				await AfterDelete(entity);
			}

			return _mapper.Map<TModel>(entity);
		}

		public virtual async Task BeforeDelete(TEntity entity)
		{

		}

		public virtual async Task AfterDelete(TEntity entity)
		{

		}
	}
}
