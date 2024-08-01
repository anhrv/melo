using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class Album
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

    public virtual ICollection<AlbumArtist> AlbumArtists { get; set; } = new List<AlbumArtist>();

    public virtual ICollection<AlbumGenre> AlbumGenres { get; set; } = new List<AlbumGenre>();

    public virtual ICollection<SongAlbum> SongAlbums { get; set; } = new List<SongAlbum>();

    public virtual ICollection<UserAlbumActivity> UserAlbumActivities { get; set; } = new List<UserAlbumActivity>();

    public virtual ICollection<UserAlbumLike> UserAlbumLikes { get; set; } = new List<UserAlbumLike>();
}
