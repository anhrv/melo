using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class AddToPlaylistsRequest
	{
		[MinLength(1, ErrorMessage = "At least one playlist needs to be provided")]
		[NoDuplicates(ErrorMessage = "Playlists have to be unique")]
		public List<int> PlaylistIds { get; set; } = new List<int>();
    }
}
