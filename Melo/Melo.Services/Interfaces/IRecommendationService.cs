using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IRecommendationService
	{
		Task<bool> UserHasSongInteractions();
		Task<List<SongResponse>> GetSongRecommendations(int size);
		Task<List<SongResponse>> GetPopularSongs(int size);

		Task<bool> UserHasArtistInteractions();
		Task<List<ArtistResponse>> GetArtistRecommendations(int size);
		Task<List<ArtistResponse>> GetPopularArtists(int size);

		Task<bool> UserHasAlbumInteractions();
		Task<List<AlbumResponse>> GetAlbumRecommendations(int size);
		Task<List<AlbumResponse>> GetPopularAlbums(int size);
	}
}
