using Mapster;
using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Mappings
{
	public class PlaylistMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<SongPlaylist, PlaylistSongResponse>()
				.Map(dest => dest,
					 src => src.Song)
				.Map(dest => dest.SongOrder,
					 src => src.SongOrder)
				.Map(dest => dest.Genres,
					 src => src.Song.SongGenres.Select(sg => sg.Genre.Adapt<GenreResponse>()))
				.Map(dest => dest.Artists,
					 src => src.Song.SongArtists.Select(sa => sa.Artist.Adapt<ArtistResponse>()));

			config.NewConfig<PlaylistUpsert, Playlist>()
				.PreserveReference(true);
		}
	}
}
