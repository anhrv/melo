using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IAlbumLikeService
	{
		Task<MessageResponse?> Like(int id);
		Task<MessageResponse?> Unlike(int id);
		Task<IsLikedResponse?> IsLiked(int id);
		Task<PagedResponse<AlbumResponse>> GetLiked(AlbumSearch request);
	}
}
