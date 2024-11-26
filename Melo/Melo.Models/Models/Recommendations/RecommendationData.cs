using Microsoft.ML.Data;

namespace Melo.Models.Recommendations
{
	public class RecommendationData
	{
		[KeyType(count: 100000)]
		public uint UserId { get; set; }
		[KeyType(count: 100000)]
		public uint EntityId { get; set; }
		public float InteractionScore { get; set; }
	}
}
