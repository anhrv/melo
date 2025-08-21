using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class Artist
{
    public int Id { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? ModifiedBy { get; set; }

    public string Name { get; set; }

    public long? LikeCount { get; set; }

    public long? ViewCount { get; set; }

    public string? ImageUrl { get; set; }

    public virtual ICollection<AlbumArtist> AlbumArtists { get; set; } = new List<AlbumArtist>();

    public virtual ICollection<ArtistGenre> ArtistGenres { get; set; } = new List<ArtistGenre>();

    public virtual ICollection<SongArtist> SongArtists { get; set; } = new List<SongArtist>();

    public virtual ICollection<UserArtistLike> UserArtistLikes { get; set; } = new List<UserArtistLike>();

    public virtual ICollection<UserArtistView> UserArtistViews { get; set; } = new List<UserArtistView>();
}
