using Melo.Models.Validation;

namespace Melo.Models
{
	public class ReorderRequest
	{
		[NoDuplicates(ErrorMessage = "Songs have to be unique")]
        public List<int> SongIds { get; set; } = new List<int>();
    }
}
