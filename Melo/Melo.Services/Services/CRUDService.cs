using MapsterMapper;
using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;
using System.Linq.Dynamic.Core;

namespace Melo.Services
{
	public class CRUDService<TEntity, TModel, TSearch, TCreate, TUpdate> : ICRUDService<TModel, TSearch, TCreate, TUpdate> where TEntity : class where TSearch : BaseSearchObject
	{
		private readonly ApplicationDbContext _context;
		private readonly IMapper _mapper;

		public CRUDService(ApplicationDbContext context, IMapper mapper)
		{
			_context = context;
			_mapper = mapper;
		}

		public virtual async Task<PagedResponse<TModel>> GetPaged(TSearch request)
		{
			List<TModel> data = new List<TModel>();

			int page = request.Page ?? 1;
			int pageSize = request.PageSize ?? 100;

			IQueryable<TEntity> query = _context.Set<TEntity>().AsQueryable();

			query = AddFilters(request, query);

			if (!string.IsNullOrEmpty(request.SortBy))
			{
				var sortingOrder = request.Ascending.HasValue && request.Ascending.Value==true ? "ascending" : "descending";
				query = query.OrderBy($"{request.SortBy} {sortingOrder}");
			}

			int totalItems = await query.CountAsync();
			int totalPages = (int)Math.Ceiling(totalItems / (double)pageSize);

			query = query.Skip((page-1) * pageSize).Take(pageSize);

			List<TEntity> list = await query.ToListAsync();

			data = _mapper.Map(list, data);

			PagedResponse<TModel> pagedResponse = new PagedResponse<TModel>
			{
				Data = data,
				Items = data.Count,
				TotalItems = totalItems,
				Page = totalItems == 0 ? 0 : page,
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

			BeforeInsert(request, entity);

			await _context.Set<TEntity>().AddAsync(entity);

			AfterInsert(request, entity);

			await _context.SaveChangesAsync();

			return _mapper.Map<TModel>(entity);
		}

		public virtual async void BeforeInsert(TCreate request, TEntity entity)
		{

		}

		public virtual async void AfterInsert(TCreate request, TEntity entity)
		{

		}

		public virtual async Task<TModel?> Update(int id, TUpdate request)
		{
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			if (entity is not null)
			{
				_mapper.Map(request, entity);

				BeforeUpdate(request, entity);

				await _context.SaveChangesAsync();

				AfterUpdate(request, entity);
			}

			return _mapper.Map<TModel>(entity);
		}

		public virtual async void BeforeUpdate(TUpdate request, TEntity entity)
		{

		}

		public virtual async void AfterUpdate(TUpdate request, TEntity entity)
		{

		}

		public virtual async Task<TModel?> Delete(int id)
		{
			TEntity? entity = await _context.Set<TEntity>().FindAsync(id);

			if (entity is not null)
			{
				BeforeDelete(entity);

				_context.Set<TEntity>().Remove(entity);

				AfterDelete(entity);

				await _context.SaveChangesAsync();
			}

			return _mapper.Map<TModel>(entity);
		}

		public virtual async void BeforeDelete(TEntity entity)
		{

		}

		public virtual async void AfterDelete(TEntity entity)
		{

		}
	}
}
