using System.ComponentModel.DataAnnotations;

namespace Melo.Models
{
	public class AlbumSongResponse : SongResponse
	{
        public int SongOrder { get; set; }
    }
}
