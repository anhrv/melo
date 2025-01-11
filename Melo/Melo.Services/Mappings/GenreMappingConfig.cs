using Mapster;
using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Mappings
{
	public class GenreMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<Genre, LovResponse>()
				.Map(dest => dest.Id,
					 src => src.Id)
				.Map(dest => dest.Name,
					 src => String.IsNullOrWhiteSpace(src.Name) ? "No name" : src.Name);
		}
	}
}
