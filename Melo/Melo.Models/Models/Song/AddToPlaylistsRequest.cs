using Melo.Models.Validation;

namespace Melo.Models
{
	public class AddToPlaylistsRequest
	{
        [NoDuplicates(ErrorMessage = "Playlists have to be unique")]
		public List<int> PlaylistIds { get; set; } = new List<int>();
    }
}
