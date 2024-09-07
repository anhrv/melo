using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface ICRUDService<TModel, TSearch, TCreate, TUpdate> where TSearch : BaseSearch
	{
		Task<PagedResponse<TModel>> GetPaged(TSearch request);
		Task<TModel?> GetById(int id);
		Task<TModel> Create(TCreate request);
		Task<TModel?> Update(int id, TUpdate request);
		Task<TModel?> Delete(int id);
	}
}
