using Melo.Core.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Melo.Core.Interfaces
{
	public interface ICRUDService<TModel, TSearch, TCreate, TUpdate> where TSearch : BaseSearchObject
	{
		Task<PagedResponse<TModel>> GetPaged(TSearch request);
		Task<TModel> GetById(Guid id);
		Task<TModel> Create(TCreate request);
		Task<TModel> Update(Guid id, TUpdate request);
		Task<TModel> Delete(Guid id);
	}
}
