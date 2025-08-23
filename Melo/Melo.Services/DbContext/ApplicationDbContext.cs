using System;
using System.Collections.Generic;
using Melo.Services.Entities;
using Microsoft.EntityFrameworkCore;

namespace Melo.Services;

public partial class ApplicationDbContext : DbContext
{
    public ApplicationDbContext()
    {
    }

    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Album> Albums { get; set; }

    public virtual DbSet<AlbumArtist> AlbumArtists { get; set; }

    public virtual DbSet<AlbumGenre> AlbumGenres { get; set; }

    public virtual DbSet<Artist> Artists { get; set; }

    public virtual DbSet<ArtistGenre> ArtistGenres { get; set; }

    public virtual DbSet<Genre> Genres { get; set; }

    public virtual DbSet<Playlist> Playlists { get; set; }

    public virtual DbSet<Role> Roles { get; set; }

    public virtual DbSet<Song> Songs { get; set; }

    public virtual DbSet<SongAlbum> SongAlbums { get; set; }

    public virtual DbSet<SongArtist> SongArtists { get; set; }

    public virtual DbSet<SongGenre> SongGenres { get; set; }

    public virtual DbSet<SongPlaylist> SongPlaylists { get; set; }

    public virtual DbSet<User> Users { get; set; }

    public virtual DbSet<UserAlbumLike> UserAlbumLikes { get; set; }

    public virtual DbSet<UserAlbumView> UserAlbumViews { get; set; }

    public virtual DbSet<UserArtistLike> UserArtistLikes { get; set; }

    public virtual DbSet<UserArtistView> UserArtistViews { get; set; }

    public virtual DbSet<UserGenreView> UserGenreViews { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    public virtual DbSet<UserSongLike> UserSongLikes { get; set; }

    public virtual DbSet<UserSongView> UserSongViews { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Album>(entity =>
        {
            entity.ToTable("Album");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(255);
            entity.Property(e => e.Playtime).HasMaxLength(255);
        });

        modelBuilder.Entity<AlbumArtist>(entity =>
        {
            entity.HasKey(e => new { e.AlbumId, e.ArtistId });

            entity.ToTable("AlbumArtist");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);

            entity.HasOne(d => d.Album).WithMany(p => p.AlbumArtists)
                .HasForeignKey(d => d.AlbumId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AlbumArtist_Album");

            entity.HasOne(d => d.Artist).WithMany(p => p.AlbumArtists)
                .HasForeignKey(d => d.ArtistId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AlbumArtist_Artist");
        });

        modelBuilder.Entity<AlbumGenre>(entity =>
        {
            entity.HasKey(e => new { e.AlbumId, e.GenreId });

            entity.ToTable("AlbumGenre");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);

            entity.HasOne(d => d.Album).WithMany(p => p.AlbumGenres)
                .HasForeignKey(d => d.AlbumId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AlbumGenre_Album");

            entity.HasOne(d => d.Genre).WithMany(p => p.AlbumGenres)
                .HasForeignKey(d => d.GenreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_AlbumGenre_Genre");
        });

        modelBuilder.Entity<Artist>(entity =>
        {
            entity.ToTable("Artist");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(255);
        });

        modelBuilder.Entity<ArtistGenre>(entity =>
        {
            entity.HasKey(e => new { e.ArtistId, e.GenreId });

            entity.ToTable("ArtistGenre");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);

            entity.HasOne(d => d.Artist).WithMany(p => p.ArtistGenres)
                .HasForeignKey(d => d.ArtistId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ArtistGenre_Artist");

            entity.HasOne(d => d.Genre).WithMany(p => p.ArtistGenres)
                .HasForeignKey(d => d.GenreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_ArtistGenre_Genre");
        });

        modelBuilder.Entity<Genre>(entity =>
        {
            entity.ToTable("Genre");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(255);
        });

        modelBuilder.Entity<Playlist>(entity =>
        {
            entity.ToTable("Playlist");

            entity.Property(e => e.Name).IsRequired().HasMaxLength(255);
            entity.Property(e => e.Playtime).HasMaxLength(255);

            entity.HasOne(d => d.User).WithMany(p => p.Playlists)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_Playlist_User");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.ToTable("Role");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(255);
        });

        modelBuilder.Entity<Song>(entity =>
        {
            entity.ToTable("Song");

            entity.Property(e => e.AudioUrl).HasMaxLength(255);
            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).IsRequired().HasMaxLength(255);
            entity.Property(e => e.Playtime).HasMaxLength(255);
        });

        modelBuilder.Entity<SongAlbum>(entity =>
        {
            entity.HasKey(e => new { e.SongId, e.AlbumId });

            entity.ToTable("SongAlbum");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);

            entity.HasOne(d => d.Album).WithMany(p => p.SongAlbums)
                .HasForeignKey(d => d.AlbumId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongAlbum_Album");

            entity.HasOne(d => d.Song).WithMany(p => p.SongAlbums)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongAlbum_Song");
        });

        modelBuilder.Entity<SongArtist>(entity =>
        {
            entity.HasKey(e => new { e.SongId, e.ArtistId });

            entity.ToTable("SongArtist");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);

            entity.HasOne(d => d.Artist).WithMany(p => p.SongArtists)
                .HasForeignKey(d => d.ArtistId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongArtist_Artist");

            entity.HasOne(d => d.Song).WithMany(p => p.SongArtists)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongArtist_Song");
        });

        modelBuilder.Entity<SongGenre>(entity =>
        {
            entity.HasKey(e => new { e.SongId, e.GenreId });

            entity.ToTable("SongGenre");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);

            entity.HasOne(d => d.Genre).WithMany(p => p.SongGenres)
                .HasForeignKey(d => d.GenreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongGenre_Genre");

            entity.HasOne(d => d.Song).WithMany(p => p.SongGenres)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongGenre_Song");
        });

        modelBuilder.Entity<SongPlaylist>(entity =>
        {
            entity.HasKey(e => new { e.SongId, e.PlaylistId });

            entity.ToTable("SongPlaylist");

            entity.HasOne(d => d.Playlist).WithMany(p => p.SongPlaylists)
                .HasForeignKey(d => d.PlaylistId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongPlaylist_Playlist");

            entity.HasOne(d => d.Song).WithMany(p => p.SongPlaylists)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_SongPlaylist_Song");
        });

        modelBuilder.Entity<User>(entity =>
        {
            entity.ToTable("User");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.Email).IsRequired().HasMaxLength(255);
            entity.Property(e => e.FirstName).HasMaxLength(255);
            entity.Property(e => e.LastName).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.UserName).IsRequired().HasMaxLength(255);
            entity.Property(e => e.Password).IsRequired().HasMaxLength(255);
            entity.Property(e => e.RefreshToken).HasMaxLength(255);
            entity.Property(e => e.StripeSubscriptionId).HasMaxLength(255);
            entity.Property(e => e.StripeCustomerId).HasMaxLength(255);
        });

        modelBuilder.Entity<UserAlbumLike>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.AlbumId });

            entity.ToTable("UserAlbumLike");

            entity.HasOne(d => d.Album).WithMany(p => p.UserAlbumLikes)
                .HasForeignKey(d => d.AlbumId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserAlbumLike_Album");

            entity.HasOne(d => d.User).WithMany(p => p.UserAlbumLikes)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserAlbumLike_User");
        });

        modelBuilder.Entity<UserAlbumView>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.AlbumId }).HasName("PK_UserAlbumActivity");

            entity.ToTable("UserAlbumView");

            entity.HasOne(d => d.Album).WithMany(p => p.UserAlbumViews)
                .HasForeignKey(d => d.AlbumId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserAlbumActivity_Album");

            entity.HasOne(d => d.User).WithMany(p => p.UserAlbumViews)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserAlbumActivity_User");
        });

        modelBuilder.Entity<UserArtistLike>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.ArtistId });

            entity.ToTable("UserArtistLike");

            entity.HasOne(d => d.Artist).WithMany(p => p.UserArtistLikes)
                .HasForeignKey(d => d.ArtistId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserArtistLike_Artist");

            entity.HasOne(d => d.User).WithMany(p => p.UserArtistLikes)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserArtistLike_User");
        });

        modelBuilder.Entity<UserArtistView>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.ArtistId }).HasName("PK_UserArtistActivity");

            entity.ToTable("UserArtistView");

            entity.HasOne(d => d.Artist).WithMany(p => p.UserArtistViews)
                .HasForeignKey(d => d.ArtistId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserArtistActivity_Album");

            entity.HasOne(d => d.User).WithMany(p => p.UserArtistViews)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserArtistActivity_User");
        });

        modelBuilder.Entity<UserGenreView>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.GenreId }).HasName("PK_UserGenreActivity");

            entity.ToTable("UserGenreView");

            entity.HasOne(d => d.Genre).WithMany(p => p.UserGenreViews)
                .HasForeignKey(d => d.GenreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserGenreActivity_Genre");

            entity.HasOne(d => d.User).WithMany(p => p.UserGenreViews)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserGenreActivity_User");
        });

        modelBuilder.Entity<UserRole>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.RoleId });

            entity.ToTable("UserRole");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);

            entity.HasOne(d => d.Role).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.RoleId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserRole_Role");

            entity.HasOne(d => d.User).WithMany(p => p.UserRoles)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserRole_User");
        });

        modelBuilder.Entity<UserSongLike>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.SongId });

            entity.ToTable("UserSongLike");

            entity.HasOne(d => d.Song).WithMany(p => p.UserSongLikes)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserSongLike_Song");

            entity.HasOne(d => d.User).WithMany(p => p.UserSongLikes)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserSongLike_User");
        });

        modelBuilder.Entity<UserSongView>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.SongId }).HasName("PK_UserSongActivity");

            entity.ToTable("UserSongView");

            entity.HasOne(d => d.Song).WithMany(p => p.UserSongViews)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserSongActivity_Song");

            entity.HasOne(d => d.User).WithMany(p => p.UserSongViews)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserSongActivity_User");
        });

        OnModelCreatingPartial(modelBuilder);

        // TEST DATA

        modelBuilder.Entity<Role>().HasData(
            new Role { Id = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Admin" },
            new Role { Id = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "User" }
        );

        modelBuilder.Entity<User>().HasData(
            new User
            {
                Id = 1,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                UserName = "admin",
                Email = "admin@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 2,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                FirstName = "User1",
                LastName = "User1",
                UserName = "user1",
                Email = "user1@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 3,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                UserName = "user2",
                Email = "user2@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 4,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                FirstName = "User3",
                LastName = "User3",
                UserName = "user3",
                Email = "user3@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 5,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                UserName = "user4",
                Email = "user4@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 6,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                FirstName = "User5",
                LastName = "User5",
                UserName = "user5",
                Email = "user5@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 7,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                UserName = "user6",
                Email = "user6@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 8,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                FirstName = "User7",
                LastName = "User7",
                UserName = "user7",
                Email = "user7@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 9,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                UserName = "user8",
                Email = "user8@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            },
            new User
            {
                Id = 10,
                CreatedAt = DateTime.UtcNow,
                CreatedBy = "system",
                FirstName = "User9",
                LastName = "User9",
                UserName = "user9",
                Email = "user9@melo.com",
                Password = "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6",
                Deleted = false
            }
        );

        modelBuilder.Entity<UserRole>().HasData(
            new UserRole { UserId = 1, RoleId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 2, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 3, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 4, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 5, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 6, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 7, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 8, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 9, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new UserRole { UserId = 10, RoleId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" }
        );

        modelBuilder.Entity<Genre>().HasData(
            new Genre { Id = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Pop", ViewCount = 45, ImageUrl = "/api/image/stream/genre/1" },
            new Genre { Id = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Rock", ViewCount = 0, ImageUrl = null },
            new Genre { Id = 3, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Metal", ViewCount = 0, ImageUrl = "/api/image/stream/genre/3" },
            new Genre { Id = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Rap", ViewCount = 32, ImageUrl = "/api/image/stream/genre/4" },
            new Genre { Id = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "RnB", ViewCount = 75, ImageUrl = null },
            new Genre { Id = 6, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Blues", ViewCount = 23, ImageUrl = "/api/image/stream/genre/6" },
            new Genre { Id = 7, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Classical", ViewCount = 0, ImageUrl = null },
            new Genre { Id = 8, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Techno", ViewCount = 0, ImageUrl = null },
            new Genre { Id = 9, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Dancehall", ViewCount = 0, ImageUrl = null },
            new Genre { Id = 10, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Jazz", ViewCount = 0, ImageUrl = null }
        );

        modelBuilder.Entity<Artist>().HasData(
            new Artist { Id = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Drake", ViewCount = 61, LikeCount = 1, ImageUrl = "/api/image/stream/artist/1" },
            new Artist { Id = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Kanye West", ViewCount = 0, LikeCount = 0, ImageUrl = "/api/image/stream/artist/2" },
            new Artist { Id = 3, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Metallica", ViewCount = 0, LikeCount = 0, ImageUrl = "/api/image/stream/artist/3" },
            new Artist { Id = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Taylor Swift", ViewCount = 16, LikeCount = 0, ImageUrl = "/api/image/stream/artist/4" },
            new Artist { Id = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Chris Brown", ViewCount = 0, LikeCount = 0, ImageUrl = null },
            new Artist { Id = 6, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Queen", ViewCount = 0, LikeCount = 0, ImageUrl = "/api/image/stream/artist/6" },
            new Artist { Id = 7, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Pink Floyd", ViewCount = 0, LikeCount = 0, ImageUrl = null },
            new Artist { Id = 8, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Lady Gaga", ViewCount = 0, LikeCount = 0, ImageUrl = null },
            new Artist { Id = 9, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "The Weeknd", ViewCount = 75, LikeCount = 1, ImageUrl = null },
            new Artist { Id = 10, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Adele", ViewCount = 23, LikeCount = 2, ImageUrl = null }
        );

        modelBuilder.Entity<ArtistGenre>().HasData(
            new ArtistGenre { ArtistId = 1, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 1, GenreId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 2, GenreId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 3, GenreId = 3, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 4, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 6, GenreId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 7, GenreId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 8, GenreId = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 9, GenreId = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new ArtistGenre { ArtistId = 10, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" }
        );

        modelBuilder.Entity<Album>().HasData(
            new Album { Id = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Iceman", DateOfRelease = DateOnly.Parse("2012-06-12"), Playtime = "0:24", PlaytimeInSeconds = 24, SongCount = 2, ViewCount = 61, LikeCount = 2, ImageUrl = "/api/image/stream/album/1" },
            new Album { Id = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "1989", DateOfRelease = null, Playtime = "0:58", PlaytimeInSeconds = 58, SongCount = 4, ViewCount = 16, LikeCount = 0, ImageUrl = "/api/image/stream/album/2" },
            new Album { Id = 3, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Starboy", DateOfRelease = DateOnly.Parse("1999-11-11"), Playtime = "0:53", PlaytimeInSeconds = 53, SongCount = 3, ViewCount = 75, LikeCount = 1, ImageUrl = "/api/image/stream/album/3" }
        );

        modelBuilder.Entity<AlbumGenre>().HasData(
            new AlbumGenre { AlbumId = 1, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new AlbumGenre { AlbumId = 1, GenreId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new AlbumGenre { AlbumId = 2, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new AlbumGenre { AlbumId = 3, GenreId = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system" }
        );

        modelBuilder.Entity<AlbumArtist>().HasData(
            new AlbumArtist { AlbumId = 1, ArtistId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new AlbumArtist { AlbumId = 2, ArtistId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new AlbumArtist { AlbumId = 3, ArtistId = 9, CreatedAt = DateTime.UtcNow, CreatedBy = "system" }
        );

        modelBuilder.Entity<Song>().HasData(
            new Song { Id = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Imagine", DateOfRelease = DateOnly.Parse("2012-06-12"), Playtime = "0:09", PlaytimeInSeconds = 9, ViewCount = 29, LikeCount = 1, ImageUrl = "/api/image/stream/album/1", AudioUrl = "/api/audio/stream/1" },
            new Song { Id = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Fast car", DateOfRelease = DateOnly.Parse("2012-06-12"), Playtime = "0:15", PlaytimeInSeconds = 15, ViewCount = 32, LikeCount = 1, ImageUrl = "/api/image/stream/album/1", AudioUrl = "/api/audio/stream/2" },
            new Song { Id = 3, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Bohemian", DateOfRelease = null, Playtime = "0:09", PlaytimeInSeconds = 9, ViewCount = 6, LikeCount = 1, ImageUrl = "/api/image/stream/album/2", AudioUrl = "/api/audio/stream/3" },
            new Song { Id = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Rhapsody", DateOfRelease = null, Playtime = "0:15", PlaytimeInSeconds = 15, ViewCount = 3, LikeCount = 0, ImageUrl = "/api/image/stream/album/2", AudioUrl = "/api/audio/stream/4" },
            new Song { Id = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Hills", DateOfRelease = null, Playtime = "0:19", PlaytimeInSeconds = 19, ViewCount = 4, LikeCount = 1, ImageUrl = "/api/image/stream/album/2", AudioUrl = "/api/audio/stream/5" },
            new Song { Id = 6, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Lulaby", DateOfRelease = null, Playtime = "0:15", PlaytimeInSeconds = 15, ViewCount = 3, LikeCount = 0, ImageUrl = "/api/image/stream/album/2", AudioUrl = "/api/audio/stream/6" },
            new Song { Id = 7, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Chicago Freestyle", DateOfRelease = DateOnly.Parse("1999-11-11"), Playtime = "0:19", PlaytimeInSeconds = 19, ViewCount = 17, LikeCount = 0, ImageUrl = "/api/image/stream/album/3", AudioUrl = "/api/audio/stream/7" },
            new Song { Id = 8, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "Headlines", DateOfRelease = DateOnly.Parse("1999-11-11"), Playtime = "0:15", PlaytimeInSeconds = 15, ViewCount = 22, LikeCount = 0, ImageUrl = "/api/image/stream/album/3", AudioUrl = "/api/audio/stream/8" },
            new Song { Id = 9, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "California Love", DateOfRelease = DateOnly.Parse("1999-11-11"), Playtime = "0:19", PlaytimeInSeconds = 19, ViewCount = 36, LikeCount = 1, ImageUrl = "/api/image/stream/album/3", AudioUrl = "/api/audio/stream/9" },
            new Song { Id = 10, CreatedAt = DateTime.UtcNow, CreatedBy = "system", Name = "On God", DateOfRelease = null, Playtime = "0:09", PlaytimeInSeconds = 9, ViewCount = 23, LikeCount = 2, ImageUrl = null, AudioUrl = "/api/audio/stream/10" }
        );

        modelBuilder.Entity<SongAlbum>().HasData(
            new SongAlbum { AlbumId = 1, SongId = 1, SongOrder = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 1, SongId = 2, SongOrder = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 2, SongId = 3, SongOrder = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 2, SongId = 4, SongOrder = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 2, SongId = 5, SongOrder = 3, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 2, SongId = 6, SongOrder = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 3, SongId = 7, SongOrder = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 3, SongId = 8, SongOrder = 2, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongAlbum { AlbumId = 3, SongId = 9, SongOrder = 3, CreatedAt = DateTime.UtcNow, CreatedBy = "system" }
        );

        modelBuilder.Entity<SongArtist>().HasData(
            new SongArtist { SongId = 1, ArtistId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 2, ArtistId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 3, ArtistId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 4, ArtistId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 5, ArtistId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 6, ArtistId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 7, ArtistId = 9, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 8, ArtistId = 9, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 9, ArtistId = 9, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongArtist { SongId = 10, ArtistId = 10, CreatedAt = DateTime.UtcNow, CreatedBy = "system" }
        );

        modelBuilder.Entity<SongGenre>().HasData(
            new SongGenre { SongId = 1, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 2, GenreId = 4, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 3, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 4, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 5, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 6, GenreId = 1, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 7, GenreId = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 8, GenreId = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 9, GenreId = 5, CreatedAt = DateTime.UtcNow, CreatedBy = "system" },
            new SongGenre { SongId = 10, GenreId = 6, CreatedAt = DateTime.UtcNow, CreatedBy = "system" }
        );

        modelBuilder.Entity<Playlist>().HasData(
            new Playlist { Id = 1, CreatedAt = DateTime.UtcNow, Name = "Playlist1", Playtime = "0:24", PlaytimeInSeconds = 24, SongCount = 2, UserId = 2 }
        );

        modelBuilder.Entity<SongPlaylist>().HasData(
            new SongPlaylist { PlaylistId = 1, SongId = 1, SongOrder = 1, CreatedAt = DateTime.UtcNow },
            new SongPlaylist { PlaylistId = 1, SongId = 2, SongOrder = 2, CreatedAt = DateTime.UtcNow }
        );

        modelBuilder.Entity<UserSongView>().HasData(
            new UserSongView { UserId = 2, SongId = 1, Count = 11, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 2, SongId = 2, Count = 13, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 2, SongId = 3, Count = 5, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 2, SongId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 2, SongId = 5, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 2, SongId = 7, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 2, SongId = 8, Count = 4, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 2, SongId = 9, Count = 17, CreatedAt = DateTime.UtcNow },

            new UserSongView { UserId = 3, SongId = 1, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 3, SongId = 2, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 3, SongId = 6, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 3, SongId = 7, Count = 12, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 3, SongId = 8, Count = 12, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 3, SongId = 9, Count = 12, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 3, SongId = 10, Count = 7, CreatedAt = DateTime.UtcNow },

            new UserSongView { UserId = 4, SongId = 2, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 4, SongId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 4, SongId = 5, Count = 2, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 4, SongId = 7, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 4, SongId = 8, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 4, SongId = 9, Count = 4, CreatedAt = DateTime.UtcNow },

            new UserSongView { UserId = 5, SongId = 1, Count = 15, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 5, SongId = 2, Count = 15, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 5, SongId = 6, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 5, SongId = 7, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 5, SongId = 8, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 5, SongId = 9, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 5, SongId = 10, Count = 10, CreatedAt = DateTime.UtcNow },

            new UserSongView { UserId = 7, SongId = 1, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 2, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 3, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 5, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 6, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 7, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 8, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 9, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 7, SongId = 10, Count = 1, CreatedAt = DateTime.UtcNow },

            new UserSongView { UserId = 9, SongId = 1, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 9, SongId = 2, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 9, SongId = 7, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 9, SongId = 8, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserSongView { UserId = 9, SongId = 9, Count = 1, CreatedAt = DateTime.UtcNow },

            new UserSongView { UserId = 10, SongId = 10, Count = 5, CreatedAt = DateTime.UtcNow }
        );

        modelBuilder.Entity<UserAlbumView>().HasData(
            new UserAlbumView { UserId = 2, AlbumId = 1, Count = 24, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 3, AlbumId = 1, Count = 2, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 4, AlbumId = 1, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 5, AlbumId = 1, Count = 30, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 7, AlbumId = 1, Count = 2, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 9, AlbumId = 1, Count = 2, CreatedAt = DateTime.UtcNow },

            new UserAlbumView { UserId = 2, AlbumId = 2, Count = 7, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 3, AlbumId = 2, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 4, AlbumId = 2, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 5, AlbumId = 2, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 7, AlbumId = 2, Count = 4, CreatedAt = DateTime.UtcNow },

            new UserAlbumView { UserId = 2, AlbumId = 3, Count = 22, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 3, AlbumId = 3, Count = 36, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 4, AlbumId = 3, Count = 8, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 5, AlbumId = 3, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 7, AlbumId = 3, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserAlbumView { UserId = 9, AlbumId = 3, Count = 3, CreatedAt = DateTime.UtcNow }
        );

        modelBuilder.Entity<UserGenreView>().HasData(
            new UserGenreView { UserId = 2, GenreId = 1, Count = 18, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 3, GenreId = 1, Count = 2, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 4, GenreId = 1, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 5, GenreId = 1, Count = 16, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 7, GenreId = 1, Count = 5, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 9, GenreId = 1, Count = 1, CreatedAt = DateTime.UtcNow },

            new UserGenreView { UserId = 2, GenreId = 4, Count = 13, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 3, GenreId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 4, GenreId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 5, GenreId = 4, Count = 15, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 7, GenreId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 9, GenreId = 4, Count = 1, CreatedAt = DateTime.UtcNow },

            new UserGenreView { UserId = 2, GenreId = 5, Count = 22, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 3, GenreId = 5, Count = 36, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 4, GenreId = 5, Count = 8, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 5, GenreId = 5, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 7, GenreId = 5, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 9, GenreId = 5, Count = 3, CreatedAt = DateTime.UtcNow },

            new UserGenreView { UserId = 3, GenreId = 6, Count = 7, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 5, GenreId = 6, Count = 10, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 7, GenreId = 6, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserGenreView { UserId = 10, GenreId = 6, Count = 5, CreatedAt = DateTime.UtcNow }
        );

        modelBuilder.Entity<UserArtistView>().HasData(
            new UserArtistView { UserId = 2, ArtistId = 1, Count = 24, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 3, ArtistId = 1, Count = 2, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 4, ArtistId = 1, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 5, ArtistId = 1, Count = 30, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 7, ArtistId = 1, Count = 2, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 9, ArtistId = 1, Count = 2, CreatedAt = DateTime.UtcNow },

            new UserArtistView { UserId = 2, ArtistId = 4, Count = 7, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 3, ArtistId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 4, ArtistId = 4, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 5, ArtistId = 4, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 7, ArtistId = 4, Count = 4, CreatedAt = DateTime.UtcNow },

            new UserArtistView { UserId = 2, ArtistId = 9, Count = 22, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 3, ArtistId = 9, Count = 36, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 4, ArtistId = 9, Count = 8, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 5, ArtistId = 9, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 7, ArtistId = 9, Count = 3, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 9, ArtistId = 9, Count = 3, CreatedAt = DateTime.UtcNow },

            new UserArtistView { UserId = 3, ArtistId = 10, Count = 7, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 5, ArtistId = 10, Count = 10, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 7, ArtistId = 10, Count = 1, CreatedAt = DateTime.UtcNow },
            new UserArtistView { UserId = 10, ArtistId = 10, Count = 5, CreatedAt = DateTime.UtcNow }
        );

        modelBuilder.Entity<UserSongLike>().HasData(
            new UserSongLike { UserId = 2, SongId = 1, CreatedAt = DateTime.UtcNow },
            new UserSongLike { UserId = 2, SongId = 2, CreatedAt = DateTime.UtcNow },
            new UserSongLike { UserId = 2, SongId = 9, CreatedAt = DateTime.UtcNow },
            new UserSongLike { UserId = 2, SongId = 3, CreatedAt = DateTime.UtcNow },
            new UserSongLike { UserId = 3, SongId = 10, CreatedAt = DateTime.UtcNow },
            new UserSongLike { UserId = 5, SongId = 5, CreatedAt = DateTime.UtcNow },
            new UserSongLike { UserId = 10, SongId = 10, CreatedAt = DateTime.UtcNow }
        );

        modelBuilder.Entity<UserAlbumLike>().HasData(
            new UserAlbumLike { UserId = 3, AlbumId = 1, CreatedAt = DateTime.UtcNow },
            new UserAlbumLike { UserId = 3, AlbumId = 3, CreatedAt = DateTime.UtcNow },
            new UserAlbumLike { UserId = 5, AlbumId = 1, CreatedAt = DateTime.UtcNow }
        );

		modelBuilder.Entity<UserArtistLike>().HasData(
			new UserArtistLike { UserId = 3, ArtistId = 9, CreatedAt = DateTime.UtcNow },
			new UserArtistLike { UserId = 5, ArtistId = 1, CreatedAt = DateTime.UtcNow },
			new UserArtistLike { UserId = 5, ArtistId = 10, CreatedAt = DateTime.UtcNow },
			new UserArtistLike { UserId = 10, ArtistId = 10, CreatedAt = DateTime.UtcNow }
		);

	}

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
