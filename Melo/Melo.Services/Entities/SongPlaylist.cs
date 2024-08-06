using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class SongPlaylist
{
    public int SongId { get; set; }

    public int PlaylistId { get; set; }

    public DateTime? CreatedAt { get; set; }

    public virtual Playlist Playlist { get; set; } = null!;

    public virtual Song Song { get; set; } = null!;
}
