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

			config.NewConfig<Song, LovResponse>()
				.Map(dest => dest.Id,
				     src => src.Id)
				.Map(dest => dest.Name,
				     src => (String.IsNullOrWhiteSpace(src.Name) ? "No name" : src.Name) + (src.SongArtists.Any() ? $" - {string.Join(" & ", src.SongArtists.Select(sa => String.IsNullOrWhiteSpace(sa.Artist.Name) ? "No name" : sa.Artist.Name))}" : ""));

			config.NewConfig<SongUpsert, Song>()
				.PreserveReference(true);
		}
	}
}
