using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class Playlist
{
    public int Id { get; set; }

    public DateTime? CreatedAt { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? Name { get; set; }

    public string? Playtime { get; set; }

    public int? PlaytimeInSeconds { get; set; }

    public int? SongCount { get; set; }

    public int? UserId { get; set; }

    public virtual ICollection<SongPlaylist> SongPlaylists { get; set; } = new List<SongPlaylist>();

    public virtual User? User { get; set; }
}
