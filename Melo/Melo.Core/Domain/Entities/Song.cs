using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class Song
{
    public Guid Id { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? ModifiedBy { get; set; }

    public DateOnly? DateOfRelease { get; set; }

    public string? Name { get; set; }

    public string? Playtime { get; set; }

    public int? PlaytimeInSeconds { get; set; }

    public string? ImageUrl { get; set; }

    public string? AudioUrl { get; set; }

    public virtual ICollection<SongAlbum> SongAlbums { get; set; } = new List<SongAlbum>();

    public virtual ICollection<SongArtist> SongArtists { get; set; } = new List<SongArtist>();

    public virtual ICollection<SongGenre> SongGenres { get; set; } = new List<SongGenre>();

    public virtual ICollection<SongPlaylist> SongPlaylists { get; set; } = new List<SongPlaylist>();

    public virtual ICollection<UserSongActivity> UserSongActivities { get; set; } = new List<UserSongActivity>();

    public virtual ICollection<UserSongLike> UserSongLikes { get; set; } = new List<UserSongLike>();
}
