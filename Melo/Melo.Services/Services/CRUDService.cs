using MapsterMapper;
using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace Melo.Services
{
	public class CRUDService<TEntity, TResponse, TSearch, TInsert, TUpdate> : ICRUDService<TResponse, TSearch, TInsert, TUpdate> where TEntity : class where TSearch : BaseSearch
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

		public virtual async Task<PagedResponse<TResponse>> GetPaged(TSearch request)
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

			List<TResponse> data = _mapper.Map<List<TResponse>>(list);

			PagedResponse<TResponse> pagedResponse = new PagedResponse<TResponse>
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

		public virtual async Task<List<LovResponse>> GetLov()
		{
			List<TEntity> data = await _context.Set<TEntity>().ToListAsync();

			return _mapper.Map<List<LovResponse>>(data);
		}

		public virtual async Task<TResponse?> GetById(int id)
		{ 
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			return _mapper.Map<TResponse>(entity);
		}

		public virtual async Task<TResponse> Create(TInsert request)
		{
			TEntity entity = _mapper.Map<TEntity>(request);

			await BeforeInsert(request, entity);

			await _context.Set<TEntity>().AddAsync(entity);

			await _context.SaveChangesAsync();

			await AfterInsert(request, entity);

			return _mapper.Map<TResponse>(entity);
		}

		public virtual async Task BeforeInsert(TInsert request, TEntity entity)
		{

		}

		public virtual async Task AfterInsert(TInsert request, TEntity entity)
		{

		}

		public virtual async Task<TResponse?> Update(int id, TUpdate request)
		{
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			if (entity is not null)
			{
				_mapper.Map(request, entity);

				await BeforeUpdate(request, entity);

				await _context.SaveChangesAsync();

				await AfterUpdate(request, entity);
			}

			return _mapper.Map<TResponse>(entity);
		}

		public virtual async Task BeforeUpdate(TUpdate request, TEntity entity)
		{

		}

		public virtual async Task AfterUpdate(TUpdate request, TEntity entity)
		{

		}

		public virtual async Task<TResponse?> Delete(int id)
		{
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			if (entity is not null)
			{
				await BeforeDelete(entity);

				_context.Set<TEntity>().Remove(entity);

				await _context.SaveChangesAsync();

				await AfterDelete(entity);
			}

			return _mapper.Map<TResponse>(entity);
		}

		public virtual async Task BeforeDelete(TEntity entity)
		{

		}

		public virtual async Task AfterDelete(TEntity entity)
		{

		}
	}
}
