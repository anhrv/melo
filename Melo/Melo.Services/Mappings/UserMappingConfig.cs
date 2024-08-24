using Mapster;
using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Mappings
{
	public class UserMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<User, UserResponse>()
				.Map(dest => dest.Roles,
					 src => src.UserRoles.Select(ag => ag.Role.Adapt<RoleResponse>()));

			config.NewConfig<UserInsert, User>()
				.PreserveReference(true);

			config.NewConfig<UserUpdate, User>()
				.PreserveReference(true);

			config.NewConfig<RegisterRequest, User>()
				.PreserveReference(true);
		}
	}
}
