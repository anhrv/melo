using System;
using System.Collections.Generic;

namespace Melo.Services.Entities;

public partial class User
{
    public int Id { get; set; }

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

	public string? Password { get; set; }

	public string? RefreshToken { get; set; }

	public DateTime? RefreshTokenExpiresAt { get; set; }

    public string? StripeSubscriptionId { get; set; }

	public string? StripeCustomerId { get; set; }


	public virtual ICollection<Playlist> Playlists { get; set; } = new List<Playlist>();

    public virtual ICollection<UserAlbumLike> UserAlbumLikes { get; set; } = new List<UserAlbumLike>();

    public virtual ICollection<UserAlbumView> UserAlbumViews { get; set; } = new List<UserAlbumView>();

    public virtual ICollection<UserArtistLike> UserArtistLikes { get; set; } = new List<UserArtistLike>();

    public virtual ICollection<UserArtistView> UserArtistViews { get; set; } = new List<UserArtistView>();

    public virtual ICollection<UserGenreView> UserGenreViews { get; set; } = new List<UserGenreView>();

    public virtual ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();

    public virtual ICollection<UserSongLike> UserSongLikes { get; set; } = new List<UserSongLike>();

    public virtual ICollection<UserSongView> UserSongViews { get; set; } = new List<UserSongView>();
}
