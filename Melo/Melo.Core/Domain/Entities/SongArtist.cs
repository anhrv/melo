using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class SongArtist
{
    public Guid SongId { get; set; }

    public Guid ArtistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Artist Artist { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
