using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class Playlist
{
    public Guid Id { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? Name { get; set; }

    public string? Playtime { get; set; }

    public int? PlaytimeInSeconds { get; set; }

    public Guid? UserId { get; set; }

    public virtual ICollection<SongPlaylist> SongPlaylists { get; set; } = new List<SongPlaylist>();

    public virtual User? User { get; set; }
}
