using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface ISongLikeService
	{
		Task<MessageResponse?> Like(int id);
		Task<MessageResponse?> Unlike(int id);
		Task<IsLikedResponse?> IsLiked(int id);
		Task<PagedResponse<SongResponse>> GetLiked(SongSearch request);
	}
}
