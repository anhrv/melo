using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class UserGenreActivity
{
    public Guid UserId { get; set; }

    public Guid GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public int? Count { get; set; }

    public virtual Genre Genre { get; set; } = null!;

    public virtual User User { get; set; } = null!;
}
