using Mapster;
using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Mappings
{
	public class RoleMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<Role, LovResponse>()
				.Map(dest => dest.Id,
					 src => src.Id)
				.Map(dest => dest.Name,
					 src => String.IsNullOrWhiteSpace(src.Name) ? "No name" : src.Name);
		}
	}
}
