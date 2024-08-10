using Mapster;
using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Mappings
{
	public class SongMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<Song, SongResponse>()
				.Map(dest => dest.Genres,
					 src => src.SongGenres.Select(sg => sg.Genre.Adapt<GenreResponse>()))
				.Map(dest => dest.Artists,
					 src => src.SongArtists.Select(sg => sg.Artist.Adapt<ArtistResponse>()));

			config.NewConfig<SongUpsert, Song>()
				.PreserveReference(true);
		}
	}
}
