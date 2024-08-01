using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class Genre
{
    public Guid Id { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? ModifiedBy { get; set; }

    public string? Name { get; set; }

    public virtual ICollection<AlbumGenre> AlbumGenres { get; set; } = new List<AlbumGenre>();

    public virtual ICollection<ArtistGenre> ArtistGenres { get; set; } = new List<ArtistGenre>();

    public virtual ICollection<SongGenre> SongGenres { get; set; } = new List<SongGenre>();

    public virtual ICollection<UserGenreActivity> UserGenreActivities { get; set; } = new List<UserGenreActivity>();
}
