using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Melo.Models
{
	public class BaseSearchObject
	{
		public int? Page {  get; set; }
		public int? PageSize { get; set; }
		public string? SortBy { get; set; }
		public bool? Ascending { get; set; }
	}
}
