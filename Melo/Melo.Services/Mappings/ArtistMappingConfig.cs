using Mapster;
using Melo.Models;
using Melo.Services.Entities;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Melo.Services.Mappings
{
	public class ArtistMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<Artist, ArtistResponse>()
				.Map(dest => dest.Genres,
					 src => src.ArtistGenres.Select(ag => ag.Genre.Adapt<GenreResponse>()));

			config.NewConfig<ArtistUpsert, Artist>()
				.PreserveReference(true);
		}
	}
}
