using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class AlbumGenre
{
    public Guid AlbumId { get; set; }

    public Guid GenreId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual Genre Genre { get; set; } = null!;
}
