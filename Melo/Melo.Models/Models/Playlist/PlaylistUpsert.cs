using Melo.Models.Validation;
using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class PlaylistUpsert
	{
		[Required(ErrorMessage = "Playlist name is required")]
		public string Name { get; set; }
	}
}
