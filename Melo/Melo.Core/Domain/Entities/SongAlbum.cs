using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class SongAlbum
{
    public Guid SongId { get; set; }

    public Guid AlbumId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public int? SongOrder { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
