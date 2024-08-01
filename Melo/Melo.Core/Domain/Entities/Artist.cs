using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class Artist
{
    public Guid Id { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? ModifiedBy { get; set; }

    public string? Name { get; set; }

    public string? ImageUrl { get; set; }

    public virtual ICollection<AlbumArtist> AlbumArtists { get; set; } = new List<AlbumArtist>();

    public virtual ICollection<ArtistGenre> ArtistGenres { get; set; } = new List<ArtistGenre>();

    public virtual ICollection<SongArtist> SongArtists { get; set; } = new List<SongArtist>();

    public virtual ICollection<UserArtistActivity> UserArtistActivities { get; set; } = new List<UserArtistActivity>();

    public virtual ICollection<UserArtistLike> UserArtistLikes { get; set; } = new List<UserArtistLike>();
}
