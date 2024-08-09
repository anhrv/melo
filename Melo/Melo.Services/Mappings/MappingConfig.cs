using Mapster;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace Melo.Services.Mapping
{
	public static class MappingConfig
	{
		public static void RegisterMappings()
		{
			TypeAdapterConfig.GlobalSettings.Scan(Assembly.GetExecutingAssembly());
		}
	}
}
