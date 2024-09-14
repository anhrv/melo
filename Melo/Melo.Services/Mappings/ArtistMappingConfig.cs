using Mapster;
using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Mappings
{
	public class ArtistMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<Artist, ArtistResponse>()
				.Map(dest => dest.Genres,
					 src => src.ArtistGenres.Select(ag => ag.Genre.Adapt<GenreResponse>()));

			config.NewConfig<UserArtistLike, ArtistResponse>()
				.Map(dest => dest,
					 src => src.Artist)
				.Map(dest => dest.Genres,
					 src => src.Artist.ArtistGenres.Select(ag => ag.Genre.Adapt<GenreResponse>()));

			config.NewConfig<ArtistUpsert, Artist>()
				.PreserveReference(true);
		}
	}
}
