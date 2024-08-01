using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class SongPlaylist
{
    public Guid SongId { get; set; }

    public Guid PlaylistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Playlist Playlist { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
