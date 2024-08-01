using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class ArtistGenre
{
    public Guid ArtistId { get; set; }

    public Guid GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Artist Artist { get; set; } = null!;

    public virtual Genre Genre { get; set; } = null!;
}
