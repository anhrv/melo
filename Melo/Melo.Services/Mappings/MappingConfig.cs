using Mapster;
using System.Reflection;

namespace Melo.Services.Mappings
{
	public static class MappingConfig
	{
		public static void RegisterMappings()
		{
			TypeAdapterConfig.GlobalSettings.Scan(Assembly.GetExecutingAssembly());
		}
	}
}
