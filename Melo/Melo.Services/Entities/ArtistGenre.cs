using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class ArtistGenre
{
    public int ArtistId { get; set; }

    public int GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Artist Artist { get; set; } = null!;

    public virtual Genre Genre { get; set; } = null!;
}
