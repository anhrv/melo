using MapsterMapper;
using Melo.Core.Interfaces;
using Melo.Core.Models;

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Melo.Core.Services
{
	public class CRUDService<TEntity, TModel, TSearch, TCreate, TUpdate> : ICRUDService<TModel, TSearch, TCreate, TUpdate> where TSearch : BaseSearchObject
	{
		private readonly ApplicationD _context;
		private readonly IMapper _mapper;
		public CRUDService(ApplicationDbContext context, IMapper mapper)
		{
			_context = context;
			_mapper = mapper;
		}
		public virtual async Task<TModel> Insert(TInsert request)
		{
			var entity = _mapper.Map<TDatabase>(request);

			_context.Set<TDatabase>().Add(entity);
			await _context.SaveChangesAsync();

			return _mapper.Map<TModel>(entity);
		}

		public virtual async Task<TModel> Update(int id, TUpdate request)
		{
			var entity = _context.Set<TDatabase>().Find(id);
			_context.Set<TDatabase>().Attach(entity);
			_context.Set<TDatabase>().Update(entity);

			_mapper.Map(request, entity);

			await _context.SaveChangesAsync();

			return _mapper.Map<TModel>(entity);
		}

		public virtual async Task<bool> Delete(int id)
		{
			var entity = await _context.Set<TDatabase>().FindAsync(id);

			try
			{
				_context.Set<TDatabase>().Remove(entity);
				await _context.SaveChangesAsync();

				return true;
			}
			catch
			{
				return false;
			}
		}

		public Task<PagedResponse<TModel>> GetPaged(TSearch request)
		{
			throw new NotImplementedException();
		}

		public Task<TModel> GetById(Guid id)
		{
			throw new NotImplementedException();
		}

		public Task<TModel> Create(TCreate request)
		{
			TEntity entity = Mapper.Map<TEntity>(request);
			BeforeInsert(request, entity);
			_context.AddAsync(entity);
			Context.SaveChanges();


			return Mapper.Map<TModel>(entity);
		}

		public Task<TModel> Update(Guid id, TUpdate request)
		{
			throw new NotImplementedException();
		}

		public Task<TModel> Delete(Guid id)
		{
			throw new NotImplementedException();
		}
	}
}
