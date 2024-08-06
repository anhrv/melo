using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class AlbumGenre
{
    public int AlbumId { get; set; }

    public int GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual Genre Genre { get; set; } = null!;
}
