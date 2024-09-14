using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface ICRUDService<TResponse, TSearch, TInsert, TUpdate> where TSearch : BaseSearch
	{
		Task<PagedResponse<TResponse>> GetPaged(TSearch request);
		Task<TResponse?> GetById(int id);
		Task<TResponse> Create(TInsert request);
		Task<TResponse?> Update(int id, TUpdate request);
		Task<TResponse?> Delete(int id);
	}
}
