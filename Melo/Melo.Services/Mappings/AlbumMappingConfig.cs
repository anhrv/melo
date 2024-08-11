using Mapster;
using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Mappings
{
	public class AlbumMappingConfig : IRegister
	{
		public void Register(TypeAdapterConfig config)
		{
			config.NewConfig<SongAlbum, AlbumSongResponse>()
				.Map(dest => dest.SongOrder, 
					 src => src.SongOrder)
				.Map(dest => dest, 
				     src => src.Song);

			config.NewConfig<Album, AlbumResponse>()
				.Map(dest => dest.Genres,
					 src => src.AlbumGenres.Select(ag => ag.Genre.Adapt<GenreResponse>()))
				.Map(dest => dest.Artists,
					 src => src.AlbumArtists.Select(aa => aa.Artist.Adapt<ArtistResponse>()))
				.Map(dest => dest.Songs,
					 src => src.SongAlbums.Select(sa => sa.Adapt<AlbumSongResponse>()).ToList());

			config.NewConfig<AlbumUpsert, Album>()
				.PreserveReference(true);
		}
	}
}
