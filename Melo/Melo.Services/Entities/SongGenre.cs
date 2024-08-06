using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class SongGenre
{
    public int SongId { get; set; }

    public int GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Genre Genre { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
