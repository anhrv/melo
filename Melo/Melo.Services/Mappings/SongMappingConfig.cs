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

			config.NewConfig<UserSongLike, SongResponse>()
				.Map(dest => dest,
					 src => src.Song)
				.Map(dest => dest.Genres,
					 src => src.Song.SongGenres.Select(sg => sg.Genre.Adapt<GenreResponse>()))
				.Map(dest => dest.Artists,
					 src => src.Song.SongArtists.Select(sa => sa.Artist.Adapt<ArtistResponse>()));

			config.NewConfig<SongInsert, Song>()
				.PreserveReference(true);

			config.NewConfig<SongUpdate, Song>()
				.PreserveReference(true);
		}
	}
}
