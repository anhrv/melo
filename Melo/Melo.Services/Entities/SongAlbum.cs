using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class SongAlbum
{
    public int SongId { get; set; }

    public int AlbumId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

	public DateTime? ModifiedAt { get; set; }

	public string? ModifiedBy { get; set; }

	public int? SongOrder { get; set; }

    public virtual Album Album { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
