using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class AlbumArtist
{
    public Guid AlbumId { get; set; }

    public Guid ArtistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual Artist Artist { get; set; } = null!;
}
