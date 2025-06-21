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
				.Map(dest => dest,
					src => src.Song.Adapt<SongResponse>())
				.Map(dest => dest.SongOrder,
					 src => src.SongOrder);

			config.NewConfig<Album, AlbumResponse>()
				.Map(dest => dest.Genres,
					 src => src.AlbumGenres.Select(ag => ag.Genre.Adapt<GenreResponse>()))
				.Map(dest => dest.Artists,
					 src => src.AlbumArtists.Select(aa => aa.Artist.Adapt<ArtistResponse>()))
				.Map(dest => dest.Songs,
					 src => src.SongAlbums.Select(sa => sa.Adapt<AlbumSongResponse>()).ToList());

			config.NewConfig<UserAlbumLike, AlbumResponse>()
				.Map(dest => dest,
					 src => src.Album)
				.Map(dest => dest.Genres,
					 src => src.Album.AlbumGenres.Select(ag => ag.Genre.Adapt<GenreResponse>()))
				.Map(dest => dest.Artists,
					 src => src.Album.AlbumArtists.Select(aa => aa.Artist.Adapt<ArtistResponse>()));

			config.NewConfig<Album, LovResponse>()
				.Map(dest => dest.Id,
					 src => src.Id)
				.Map(dest => dest.Name,
					 src => (String.IsNullOrWhiteSpace(src.Name) ? "No name" : src.Name) + (src.AlbumArtists.Any() ? $" - {string.Join(" & ", src.AlbumArtists.Select(sa => String.IsNullOrWhiteSpace(sa.Artist.Name) ? "No name" : sa.Artist.Name))}" : ""));

			config.NewConfig<AlbumUpsert, Album>()
				.PreserveReference(true);
		}
	}
}
