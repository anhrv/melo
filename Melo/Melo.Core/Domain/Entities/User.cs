using System;
using System.Collections.Generic;

namespace Melo.Core.Domain.Entities;

public partial class User
{
    public Guid Id { get; set; }

    public DateTime? CreatedAt { get; set; }

    public string? CreatedBy { get; set; }

    public DateTime? ModifiedAt { get; set; }

    public string? ModifiedBy { get; set; }

    public string? FirstName { get; set; }

    public string? LastName { get; set; }

    public string? UserName { get; set; }

    public string? Email { get; set; }

    public string? Phone { get; set; }

    public bool? Subscribed { get; set; }

    public DateTime? SubscriptionStart { get; set; }

    public DateTime? SubscriptionEnd { get; set; }

    public bool? Deleted { get; set; }

    public virtual ICollection<Playlist> Playlists { get; set; } = new List<Playlist>();

    public virtual ICollection<UserAlbumActivity> UserAlbumActivities { get; set; } = new List<UserAlbumActivity>();

    public virtual ICollection<UserAlbumLike> UserAlbumLikes { get; set; } = new List<UserAlbumLike>();

    public virtual ICollection<UserArtistActivity> UserArtistActivities { get; set; } = new List<UserArtistActivity>();

    public virtual ICollection<UserArtistLike> UserArtistLikes { get; set; } = new List<UserArtistLike>();

    public virtual ICollection<UserGenreActivity> UserGenreActivities { get; set; } = new List<UserGenreActivity>();

    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();

    public virtual ICollection<UserSongActivity> UserSongActivities { get; set; } = new List<UserSongActivity>();

    public virtual ICollection<UserSongLike> UserSongLikes { get; set; } = new List<UserSongLike>();
}
