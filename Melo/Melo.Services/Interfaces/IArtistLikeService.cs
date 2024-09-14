using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface IArtistLikeService
	{ 
		Task<MessageResponse?> Like(int id);
		Task<MessageResponse?> Unlike(int id);
		Task<IsLikedResponse?> IsLiked(int id);
		Task<PagedResponse<ArtistResponse>> GetLiked(ArtistSearch request);
	}
}
