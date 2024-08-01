using System;
using System.Collections.Generic;
using Melo.Core.Domain.Entities;
using Microsoft.EntityFrameworkCore;

namespace Melo.Core;

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

    public virtual DbSet<UserAlbumActivity> UserAlbumActivities { get; set; }

    public virtual DbSet<UserAlbumLike> UserAlbumLikes { get; set; }

    public virtual DbSet<UserArtistActivity> UserArtistActivities { get; set; }

    public virtual DbSet<UserArtistLike> UserArtistLikes { get; set; }

    public virtual DbSet<UserGenreActivity> UserGenreActivities { get; set; }

    public virtual DbSet<UserRole> UserRoles { get; set; }

    public virtual DbSet<UserSongActivity> UserSongActivities { get; set; }

    public virtual DbSet<UserSongLike> UserSongLikes { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.Entity<Album>(entity =>
        {
            entity.ToTable("Album");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).HasMaxLength(255);
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

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).HasMaxLength(255);
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

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).HasMaxLength(255);
        });

        modelBuilder.Entity<Playlist>(entity =>
        {
            entity.ToTable("Playlist");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.Name).HasMaxLength(255);
            entity.Property(e => e.Playtime).HasMaxLength(255);

            entity.HasOne(d => d.User).WithMany(p => p.Playlists)
                .HasForeignKey(d => d.UserId)
                .HasConstraintName("FK_Playlist_User");
        });

        modelBuilder.Entity<Role>(entity =>
        {
            entity.ToTable("Role");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).HasMaxLength(255);
        });

        modelBuilder.Entity<Song>(entity =>
        {
            entity.ToTable("Song");

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.AudioUrl).HasMaxLength(255);
            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.ImageUrl).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Name).HasMaxLength(255);
            entity.Property(e => e.Playtime).HasMaxLength(255);
        });

        modelBuilder.Entity<SongAlbum>(entity =>
        {
            entity.HasKey(e => new { e.SongId, e.AlbumId });

            entity.ToTable("SongAlbum");

            entity.Property(e => e.CreatedBy).HasMaxLength(255);

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

            entity.Property(e => e.Id).ValueGeneratedNever();
            entity.Property(e => e.CreatedBy).HasMaxLength(255);
            entity.Property(e => e.Email).HasMaxLength(255);
            entity.Property(e => e.FirstName).HasMaxLength(255);
            entity.Property(e => e.LastName).HasMaxLength(255);
            entity.Property(e => e.ModifiedBy).HasMaxLength(255);
            entity.Property(e => e.Phone).HasMaxLength(255);
            entity.Property(e => e.UserName).HasMaxLength(255);
        });

        modelBuilder.Entity<UserAlbumActivity>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.AlbumId });

            entity.ToTable("UserAlbumActivity");

            entity.HasOne(d => d.Album).WithMany(p => p.UserAlbumActivities)
                .HasForeignKey(d => d.AlbumId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserAlbumActivity_Album");

            entity.HasOne(d => d.User).WithMany(p => p.UserAlbumActivities)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserAlbumActivity_User");
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

        modelBuilder.Entity<UserArtistActivity>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.ArtistId });

            entity.ToTable("UserArtistActivity");

            entity.HasOne(d => d.Artist).WithMany(p => p.UserArtistActivities)
                .HasForeignKey(d => d.ArtistId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserArtistActivity_Album");

            entity.HasOne(d => d.User).WithMany(p => p.UserArtistActivities)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserArtistActivity_User");
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

        modelBuilder.Entity<UserGenreActivity>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.GenreId });

            entity.ToTable("UserGenreActivity");

            entity.HasOne(d => d.Genre).WithMany(p => p.UserGenreActivities)
                .HasForeignKey(d => d.GenreId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserGenreActivity_Genre");

            entity.HasOne(d => d.User).WithMany(p => p.UserGenreActivities)
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

        modelBuilder.Entity<UserSongActivity>(entity =>
        {
            entity.HasKey(e => new { e.UserId, e.SongId });

            entity.ToTable("UserSongActivity");

            entity.HasOne(d => d.Song).WithMany(p => p.UserSongActivities)
                .HasForeignKey(d => d.SongId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserSongActivity_Song");

            entity.HasOne(d => d.User).WithMany(p => p.UserSongActivities)
                .HasForeignKey(d => d.UserId)
                .OnDelete(DeleteBehavior.ClientSetNull)
                .HasConstraintName("FK_UserSongActivity_User");
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

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}
