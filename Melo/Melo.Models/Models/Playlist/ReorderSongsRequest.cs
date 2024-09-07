using Melo.Models.Validation;

namespace Melo.Models
{
	public class ReorderSongsRequest
	{
		[NoDuplicates(ErrorMessage = "Songs have to be unique")]
        public List<int> SongIds { get; set; } = new List<int>();
    }
}
