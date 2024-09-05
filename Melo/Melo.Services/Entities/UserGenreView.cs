using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class UserGenreView
{
    public int UserId { get; set; }

    public int GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

	public DateTime? ModifiedAt { get; set; }

	public int? Count { get; set; }

    public virtual Genre Genre { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
