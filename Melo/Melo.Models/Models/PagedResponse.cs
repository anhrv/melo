using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Melo.Models
{
	public class PagedResponse<TModel>
	{
		public int Page {  get; set; }
		public int? PrevPage { get; set; }
		public int? NextPage { get; set; }
		public int TotalPages { get; set; }
		public int TotalItems { get; set; }
		public int Items {  get; set; }
		public List<TModel> Data { get; set; } = new List<TModel>();
	}
}
