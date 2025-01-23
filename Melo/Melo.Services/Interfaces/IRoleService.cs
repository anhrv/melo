using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IRoleService
	{
		Task<PagedResponse<LovResponse>> GetLov(LovSearch request);
	}
}
