using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class SongArtist
{
    public int SongId { get; set; }

    public int ArtistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Artist Artist { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
