using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class AlbumArtist
{
    public int AlbumId { get; set; }

    public int ArtistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual Artist Artist { get; set; } = null!;
}
