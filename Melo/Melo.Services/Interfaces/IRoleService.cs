namespace Melo.Services.Interfaces
{
	public interface IRoleService
	{
		Task<int> GetRoleIdByName(string name);
	}
}
