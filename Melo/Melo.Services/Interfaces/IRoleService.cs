using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IRoleService
	{
		Task<List<LovResponse>> GetLov();
	}
}
