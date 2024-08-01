using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class SongGenre
{
    public Guid SongId { get; set; }

    public Guid GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Genre Genre { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
