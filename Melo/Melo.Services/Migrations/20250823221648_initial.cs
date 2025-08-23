using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace Melo.Services.Migrations
{
    /// <inheritdoc />
    public partial class initial : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Album",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    DateOfRelease = table.Column<DateOnly>(type: "date", nullable: true),
                    Name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Playtime = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    PlaytimeInSeconds = table.Column<int>(type: "int", nullable: true),
                    SongCount = table.Column<int>(type: "int", nullable: true),
                    LikeCount = table.Column<long>(type: "bigint", nullable: true),
                    ViewCount = table.Column<long>(type: "bigint", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Album", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Artist",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    Name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    LikeCount = table.Column<long>(type: "bigint", nullable: true),
                    ViewCount = table.Column<long>(type: "bigint", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Artist", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Genre",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    Name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    ViewCount = table.Column<long>(type: "bigint", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Genre", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Role",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    Name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Role", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "Song",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    DateOfRelease = table.Column<DateOnly>(type: "date", nullable: true),
                    Name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Playtime = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    PlaytimeInSeconds = table.Column<int>(type: "int", nullable: true),
                    LikeCount = table.Column<long>(type: "bigint", nullable: true),
                    ViewCount = table.Column<long>(type: "bigint", nullable: true),
                    ImageUrl = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    AudioUrl = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Song", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "User",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    FirstName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    LastName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    UserName = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Email = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Subscribed = table.Column<bool>(type: "bit", nullable: true),
                    SubscriptionStart = table.Column<DateTime>(type: "datetime2", nullable: true),
                    SubscriptionEnd = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Deleted = table.Column<bool>(type: "bit", nullable: true),
                    Password = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    RefreshToken = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    RefreshTokenExpiresAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    StripeSubscriptionId = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    StripeCustomerId = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_User", x => x.Id);
                });

            migrationBuilder.CreateTable(
                name: "AlbumArtist",
                columns: table => new
                {
                    AlbumId = table.Column<int>(type: "int", nullable: false),
                    ArtistId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AlbumArtist", x => new { x.AlbumId, x.ArtistId });
                    table.ForeignKey(
                        name: "FK_AlbumArtist_Album",
                        column: x => x.AlbumId,
                        principalTable: "Album",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_AlbumArtist_Artist",
                        column: x => x.ArtistId,
                        principalTable: "Artist",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "AlbumGenre",
                columns: table => new
                {
                    AlbumId = table.Column<int>(type: "int", nullable: false),
                    GenreId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AlbumGenre", x => new { x.AlbumId, x.GenreId });
                    table.ForeignKey(
                        name: "FK_AlbumGenre_Album",
                        column: x => x.AlbumId,
                        principalTable: "Album",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_AlbumGenre_Genre",
                        column: x => x.GenreId,
                        principalTable: "Genre",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "ArtistGenre",
                columns: table => new
                {
                    ArtistId = table.Column<int>(type: "int", nullable: false),
                    GenreId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ArtistGenre", x => new { x.ArtistId, x.GenreId });
                    table.ForeignKey(
                        name: "FK_ArtistGenre_Artist",
                        column: x => x.ArtistId,
                        principalTable: "Artist",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_ArtistGenre_Genre",
                        column: x => x.GenreId,
                        principalTable: "Genre",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SongAlbum",
                columns: table => new
                {
                    SongId = table.Column<int>(type: "int", nullable: false),
                    AlbumId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    SongOrder = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SongAlbum", x => new { x.SongId, x.AlbumId });
                    table.ForeignKey(
                        name: "FK_SongAlbum_Album",
                        column: x => x.AlbumId,
                        principalTable: "Album",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SongAlbum_Song",
                        column: x => x.SongId,
                        principalTable: "Song",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SongArtist",
                columns: table => new
                {
                    SongId = table.Column<int>(type: "int", nullable: false),
                    ArtistId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SongArtist", x => new { x.SongId, x.ArtistId });
                    table.ForeignKey(
                        name: "FK_SongArtist_Artist",
                        column: x => x.ArtistId,
                        principalTable: "Artist",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SongArtist_Song",
                        column: x => x.SongId,
                        principalTable: "Song",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SongGenre",
                columns: table => new
                {
                    SongId = table.Column<int>(type: "int", nullable: false),
                    GenreId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SongGenre", x => new { x.SongId, x.GenreId });
                    table.ForeignKey(
                        name: "FK_SongGenre_Genre",
                        column: x => x.GenreId,
                        principalTable: "Genre",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SongGenre_Song",
                        column: x => x.SongId,
                        principalTable: "Song",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "Playlist",
                columns: table => new
                {
                    Id = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Name = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: false),
                    Playtime = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true),
                    PlaytimeInSeconds = table.Column<int>(type: "int", nullable: true),
                    SongCount = table.Column<int>(type: "int", nullable: true),
                    UserId = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Playlist", x => x.Id);
                    table.ForeignKey(
                        name: "FK_Playlist_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserAlbumLike",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    AlbumId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserAlbumLike", x => new { x.UserId, x.AlbumId });
                    table.ForeignKey(
                        name: "FK_UserAlbumLike_Album",
                        column: x => x.AlbumId,
                        principalTable: "Album",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserAlbumLike_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserAlbumView",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    AlbumId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Count = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserAlbumActivity", x => new { x.UserId, x.AlbumId });
                    table.ForeignKey(
                        name: "FK_UserAlbumActivity_Album",
                        column: x => x.AlbumId,
                        principalTable: "Album",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserAlbumActivity_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserArtistLike",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ArtistId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserArtistLike", x => new { x.UserId, x.ArtistId });
                    table.ForeignKey(
                        name: "FK_UserArtistLike_Artist",
                        column: x => x.ArtistId,
                        principalTable: "Artist",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserArtistLike_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserArtistView",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    ArtistId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Count = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserArtistActivity", x => new { x.UserId, x.ArtistId });
                    table.ForeignKey(
                        name: "FK_UserArtistActivity_Album",
                        column: x => x.ArtistId,
                        principalTable: "Artist",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserArtistActivity_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserGenreView",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    GenreId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Count = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserGenreActivity", x => new { x.UserId, x.GenreId });
                    table.ForeignKey(
                        name: "FK_UserGenreActivity_Genre",
                        column: x => x.GenreId,
                        principalTable: "Genre",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserGenreActivity_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserRole",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(255)", maxLength: 255, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserRole", x => new { x.UserId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_UserRole_Role",
                        column: x => x.RoleId,
                        principalTable: "Role",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserRole_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserSongLike",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    SongId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserSongLike", x => new { x.UserId, x.SongId });
                    table.ForeignKey(
                        name: "FK_UserSongLike_Song",
                        column: x => x.SongId,
                        principalTable: "Song",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserSongLike_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "UserSongView",
                columns: table => new
                {
                    UserId = table.Column<int>(type: "int", nullable: false),
                    SongId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    Count = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_UserSongActivity", x => new { x.UserId, x.SongId });
                    table.ForeignKey(
                        name: "FK_UserSongActivity_Song",
                        column: x => x.SongId,
                        principalTable: "Song",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_UserSongActivity_User",
                        column: x => x.UserId,
                        principalTable: "User",
                        principalColumn: "Id");
                });

            migrationBuilder.CreateTable(
                name: "SongPlaylist",
                columns: table => new
                {
                    SongId = table.Column<int>(type: "int", nullable: false),
                    PlaylistId = table.Column<int>(type: "int", nullable: false),
                    CreatedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    ModifiedAt = table.Column<DateTime>(type: "datetime2", nullable: true),
                    SongOrder = table.Column<int>(type: "int", nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_SongPlaylist", x => new { x.SongId, x.PlaylistId });
                    table.ForeignKey(
                        name: "FK_SongPlaylist_Playlist",
                        column: x => x.PlaylistId,
                        principalTable: "Playlist",
                        principalColumn: "Id");
                    table.ForeignKey(
                        name: "FK_SongPlaylist_Song",
                        column: x => x.SongId,
                        principalTable: "Song",
                        principalColumn: "Id");
                });

            migrationBuilder.InsertData(
                table: "Album",
                columns: new[] { "Id", "CreatedAt", "CreatedBy", "DateOfRelease", "ImageUrl", "LikeCount", "ModifiedAt", "ModifiedBy", "Name", "Playtime", "PlaytimeInSeconds", "SongCount", "ViewCount" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2989), "system", new DateOnly(2012, 6, 12), "/api/image/stream/album/1", 2L, null, null, "Iceman", "0:24", 24, 2, 61L },
                    { 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3167), "system", null, "/api/image/stream/album/2", 0L, null, null, "1989", "0:58", 58, 4, 16L },
                    { 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3170), "system", new DateOnly(1999, 11, 11), "/api/image/stream/album/3", 1L, null, null, "Starboy", "0:53", 53, 3, 75L }
                });

            migrationBuilder.InsertData(
                table: "Artist",
                columns: new[] { "Id", "CreatedAt", "CreatedBy", "ImageUrl", "LikeCount", "ModifiedAt", "ModifiedBy", "Name", "ViewCount" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2779), "system", "/api/image/stream/artist/1", 1L, null, null, "Drake", 61L },
                    { 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2784), "system", "/api/image/stream/artist/2", 0L, null, null, "Kanye West", 0L },
                    { 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2849), "system", "/api/image/stream/artist/3", 0L, null, null, "Metallica", 0L },
                    { 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2852), "system", "/api/image/stream/artist/4", 0L, null, null, "Taylor Swift", 16L },
                    { 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2855), "system", null, 0L, null, null, "Chris Brown", 0L },
                    { 6, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2857), "system", "/api/image/stream/artist/6", 0L, null, null, "Queen", 0L },
                    { 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2859), "system", null, 0L, null, null, "Pink Floyd", 0L },
                    { 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2861), "system", null, 0L, null, null, "Lady Gaga", 0L },
                    { 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2863), "system", null, 1L, null, null, "The Weeknd", 75L },
                    { 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2866), "system", null, 2L, null, null, "Adele", 23L }
                });

            migrationBuilder.InsertData(
                table: "Genre",
                columns: new[] { "Id", "CreatedAt", "CreatedBy", "ImageUrl", "ModifiedAt", "ModifiedBy", "Name", "ViewCount" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2720), "system", "/api/image/stream/genre/1", null, null, "Pop", 45L },
                    { 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2728), "system", null, null, null, "Rock", 0L },
                    { 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2731), "system", "/api/image/stream/genre/3", null, null, "Metal", 0L },
                    { 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2732), "system", "/api/image/stream/genre/4", null, null, "Rap", 32L },
                    { 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2734), "system", null, null, null, "RnB", 75L },
                    { 6, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2736), "system", "/api/image/stream/genre/6", null, null, "Blues", 23L },
                    { 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2738), "system", null, null, null, "Classical", 0L },
                    { 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2740), "system", null, null, null, "Techno", 0L },
                    { 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2742), "system", null, null, null, "Dancehall", 0L },
                    { 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2744), "system", null, null, null, "Jazz", 0L }
                });

            migrationBuilder.InsertData(
                table: "Role",
                columns: new[] { "Id", "CreatedAt", "CreatedBy", "ModifiedAt", "ModifiedBy", "Name" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2228), "system", null, null, "Admin" },
                    { 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2236), "system", null, null, "User" }
                });

            migrationBuilder.InsertData(
                table: "Song",
                columns: new[] { "Id", "AudioUrl", "CreatedAt", "CreatedBy", "DateOfRelease", "ImageUrl", "LikeCount", "ModifiedAt", "ModifiedBy", "Name", "Playtime", "PlaytimeInSeconds", "ViewCount" },
                values: new object[,]
                {
                    { 1, "/api/audio/stream/1", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3277), "system", new DateOnly(2012, 6, 12), "/api/image/stream/album/1", 1L, null, null, "Imagine", "0:09", 9, 29L },
                    { 2, "/api/audio/stream/2", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3289), "system", new DateOnly(2012, 6, 12), "/api/image/stream/album/1", 1L, null, null, "Fast car", "0:15", 15, 32L },
                    { 3, "/api/audio/stream/3", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3296), "system", null, "/api/image/stream/album/2", 1L, null, null, "Bohemian", "0:09", 9, 6L },
                    { 4, "/api/audio/stream/4", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3352), "system", null, "/api/image/stream/album/2", 0L, null, null, "Rhapsody", "0:15", 15, 3L },
                    { 5, "/api/audio/stream/5", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3355), "system", null, "/api/image/stream/album/2", 1L, null, null, "Hills", "0:19", 19, 4L },
                    { 6, "/api/audio/stream/6", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3358), "system", null, "/api/image/stream/album/2", 0L, null, null, "Lulaby", "0:15", 15, 3L },
                    { 7, "/api/audio/stream/7", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3361), "system", new DateOnly(1999, 11, 11), "/api/image/stream/album/3", 0L, null, null, "Chicago Freestyle", "0:19", 19, 17L },
                    { 8, "/api/audio/stream/8", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3369), "system", new DateOnly(1999, 11, 11), "/api/image/stream/album/3", 0L, null, null, "Headlines", "0:15", 15, 22L },
                    { 9, "/api/audio/stream/9", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3375), "system", new DateOnly(1999, 11, 11), "/api/image/stream/album/3", 1L, null, null, "California Love", "0:19", 19, 36L },
                    { 10, "/api/audio/stream/10", new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3381), "system", null, null, 2L, null, null, "On God", "0:09", 9, 23L }
                });

            migrationBuilder.InsertData(
                table: "User",
                columns: new[] { "Id", "CreatedAt", "CreatedBy", "Deleted", "Email", "FirstName", "LastName", "ModifiedAt", "ModifiedBy", "Password", "RefreshToken", "RefreshTokenExpiresAt", "StripeCustomerId", "StripeSubscriptionId", "Subscribed", "SubscriptionEnd", "SubscriptionStart", "UserName" },
                values: new object[,]
                {
                    { 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2546), "system", false, "admin@melo.com", null, null, null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "admin" },
                    { 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2553), "system", false, "user1@melo.com", "User1", "User1", null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user1" },
                    { 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2557), "system", false, "user2@melo.com", null, null, null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user2" },
                    { 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2560), "system", false, "user3@melo.com", "User3", "User3", null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user3" },
                    { 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2563), "system", false, "user4@melo.com", null, null, null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user4" },
                    { 6, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2566), "system", false, "user5@melo.com", "User5", "User5", null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user5" },
                    { 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2614), "system", false, "user6@melo.com", null, null, null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user6" },
                    { 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2617), "system", false, "user7@melo.com", "User7", "User7", null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user7" },
                    { 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2620), "system", false, "user8@melo.com", null, null, null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user8" },
                    { 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2623), "system", false, "user9@melo.com", "User9", "User9", null, null, "$2a$11$JIaeQiq2/1fsOh23LiUb8erdiPkwVpZ8MDtoAk18SkBJs9CPIxrd6", null, null, null, null, null, null, null, "user9" }
                });

            migrationBuilder.InsertData(
                table: "AlbumArtist",
                columns: new[] { "AlbumId", "ArtistId", "CreatedAt", "CreatedBy" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3241), "system" },
                    { 2, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3243), "system" },
                    { 3, 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3244), "system" }
                });

            migrationBuilder.InsertData(
                table: "AlbumGenre",
                columns: new[] { "AlbumId", "GenreId", "CreatedAt", "CreatedBy" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3211), "system" },
                    { 1, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3213), "system" },
                    { 2, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3215), "system" },
                    { 3, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3216), "system" }
                });

            migrationBuilder.InsertData(
                table: "ArtistGenre",
                columns: new[] { "ArtistId", "GenreId", "CreatedAt", "CreatedBy" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2899), "system" },
                    { 1, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2902), "system" },
                    { 2, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2903), "system" },
                    { 3, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2904), "system" },
                    { 4, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2905), "system" },
                    { 6, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2906), "system" },
                    { 7, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2907), "system" },
                    { 8, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2908), "system" },
                    { 9, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2909), "system" },
                    { 10, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2910), "system" }
                });

            migrationBuilder.InsertData(
                table: "Playlist",
                columns: new[] { "Id", "CreatedAt", "ModifiedAt", "Name", "Playtime", "PlaytimeInSeconds", "SongCount", "UserId" },
                values: new object[] { 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3550), null, "Playlist1", "0:24", 24, 2, 2 });

            migrationBuilder.InsertData(
                table: "SongAlbum",
                columns: new[] { "AlbumId", "SongId", "CreatedAt", "CreatedBy", "ModifiedAt", "ModifiedBy", "SongOrder" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3422), "system", null, null, 1 },
                    { 1, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3423), "system", null, null, 2 },
                    { 2, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3425), "system", null, null, 1 },
                    { 2, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3426), "system", null, null, 2 },
                    { 2, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3427), "system", null, null, 3 },
                    { 2, 6, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3429), "system", null, null, 4 },
                    { 3, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3430), "system", null, null, 1 },
                    { 3, 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3431), "system", null, null, 2 },
                    { 3, 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3433), "system", null, null, 3 }
                });

            migrationBuilder.InsertData(
                table: "SongArtist",
                columns: new[] { "ArtistId", "SongId", "CreatedAt", "CreatedBy" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3461), "system" },
                    { 1, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3463), "system" },
                    { 4, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3464), "system" },
                    { 4, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3465), "system" },
                    { 4, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3466), "system" },
                    { 4, 6, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3467), "system" },
                    { 9, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3468), "system" },
                    { 9, 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3469), "system" },
                    { 9, 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3470), "system" },
                    { 10, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3472), "system" }
                });

            migrationBuilder.InsertData(
                table: "SongGenre",
                columns: new[] { "GenreId", "SongId", "CreatedAt", "CreatedBy" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3506), "system" },
                    { 4, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3508), "system" },
                    { 1, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3509), "system" },
                    { 1, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3510), "system" },
                    { 1, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3511), "system" },
                    { 1, 6, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3512), "system" },
                    { 5, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3514), "system" },
                    { 5, 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3515), "system" },
                    { 5, 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3516), "system" },
                    { 6, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3517), "system" }
                });

            migrationBuilder.InsertData(
                table: "UserAlbumLike",
                columns: new[] { "AlbumId", "UserId", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3988) },
                    { 3, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3990) },
                    { 1, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3991) }
                });

            migrationBuilder.InsertData(
                table: "UserAlbumView",
                columns: new[] { "AlbumId", "UserId", "Count", "CreatedAt", "ModifiedAt" },
                values: new object[,]
                {
                    { 1, 2, 24, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3740), null },
                    { 2, 2, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3748), null },
                    { 3, 2, 22, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3753), null },
                    { 1, 3, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3742), null },
                    { 2, 3, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3749), null },
                    { 3, 3, 36, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3754), null },
                    { 1, 4, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3743), null },
                    { 2, 4, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3750), null },
                    { 3, 4, 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3756), null },
                    { 1, 5, 30, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3744), null },
                    { 2, 5, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3751), null },
                    { 3, 5, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3757), null },
                    { 1, 7, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3745), null },
                    { 2, 7, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3752), null },
                    { 3, 7, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3758), null },
                    { 1, 9, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3746), null },
                    { 3, 9, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3759), null }
                });

            migrationBuilder.InsertData(
                table: "UserArtistLike",
                columns: new[] { "ArtistId", "UserId", "CreatedAt" },
                values: new object[,]
                {
                    { 9, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(4017) },
                    { 1, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(4018) },
                    { 10, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(4020) },
                    { 10, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(4020) }
                });

            migrationBuilder.InsertData(
                table: "UserArtistView",
                columns: new[] { "ArtistId", "UserId", "Count", "CreatedAt", "ModifiedAt" },
                values: new object[,]
                {
                    { 1, 2, 24, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3899), null },
                    { 4, 2, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3906), null },
                    { 9, 2, 22, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3912), null },
                    { 1, 3, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3900), null },
                    { 4, 3, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3907), null },
                    { 9, 3, 36, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3913), null },
                    { 10, 3, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3918), null },
                    { 1, 4, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3902), null },
                    { 4, 4, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3908), null },
                    { 9, 4, 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3914), null },
                    { 1, 5, 30, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3903), null },
                    { 4, 5, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3909), null },
                    { 9, 5, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3915), null },
                    { 10, 5, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3919), null },
                    { 1, 7, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3904), null },
                    { 4, 7, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3910), null },
                    { 9, 7, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3916), null },
                    { 10, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3921), null },
                    { 1, 9, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3905), null },
                    { 9, 9, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3917), null },
                    { 10, 10, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3922), null }
                });

            migrationBuilder.InsertData(
                table: "UserGenreView",
                columns: new[] { "GenreId", "UserId", "Count", "CreatedAt", "ModifiedAt" },
                values: new object[,]
                {
                    { 1, 2, 18, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3797), null },
                    { 4, 2, 13, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3842), null },
                    { 5, 2, 22, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3850), null },
                    { 1, 3, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3798), null },
                    { 4, 3, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3844), null },
                    { 5, 3, 36, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3851), null },
                    { 6, 3, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3857), null },
                    { 1, 4, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3799), null },
                    { 4, 4, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3845), null },
                    { 5, 4, 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3852), null },
                    { 1, 5, 16, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3801), null },
                    { 4, 5, 15, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3846), null },
                    { 5, 5, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3854), null },
                    { 6, 5, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3858), null },
                    { 1, 7, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3802), null },
                    { 4, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3847), null },
                    { 5, 7, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3855), null },
                    { 6, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3859), null },
                    { 1, 9, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3803), null },
                    { 4, 9, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3849), null },
                    { 5, 9, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3856), null },
                    { 6, 10, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3860), null }
                });

            migrationBuilder.InsertData(
                table: "UserRole",
                columns: new[] { "RoleId", "UserId", "CreatedAt", "CreatedBy" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2665), "system" },
                    { 2, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2667), "system" },
                    { 2, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2668), "system" },
                    { 2, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2669), "system" },
                    { 2, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2671), "system" },
                    { 2, 6, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2672), "system" },
                    { 2, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2673), "system" },
                    { 2, 8, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2674), "system" },
                    { 2, 9, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2675), "system" },
                    { 2, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(2677), "system" }
                });

            migrationBuilder.InsertData(
                table: "UserSongLike",
                columns: new[] { "SongId", "UserId", "CreatedAt" },
                values: new object[,]
                {
                    { 1, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3955) },
                    { 2, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3956) },
                    { 3, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3958) },
                    { 9, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3957) },
                    { 10, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3958) },
                    { 5, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3959) },
                    { 10, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3960) }
                });

            migrationBuilder.InsertData(
                table: "UserSongView",
                columns: new[] { "SongId", "UserId", "Count", "CreatedAt", "ModifiedAt" },
                values: new object[,]
                {
                    { 1, 2, 11, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3638), null },
                    { 2, 2, 13, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3639), null },
                    { 3, 2, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3641), null },
                    { 4, 2, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3642), null },
                    { 5, 2, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3643), null },
                    { 7, 2, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3644), null },
                    { 8, 2, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3645), null },
                    { 9, 2, 17, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3646), null },
                    { 1, 3, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3647), null },
                    { 2, 3, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3649), null },
                    { 6, 3, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3650), null },
                    { 7, 3, 12, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3652), null },
                    { 8, 3, 12, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3654), null },
                    { 9, 3, 12, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3655), null },
                    { 10, 3, 7, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3656), null },
                    { 2, 4, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3657), null },
                    { 4, 4, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3658), null },
                    { 5, 4, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3659), null },
                    { 7, 4, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3660), null },
                    { 8, 4, 3, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3661), null },
                    { 9, 4, 4, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3662), null },
                    { 1, 5, 15, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3664), null },
                    { 2, 5, 15, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3665), null },
                    { 6, 5, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3666), null },
                    { 7, 5, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3667), null },
                    { 8, 5, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3668), null },
                    { 9, 5, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3669), null },
                    { 10, 5, 10, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3670), null },
                    { 1, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3671), null },
                    { 2, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3672), null },
                    { 3, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3673), null },
                    { 4, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3675), null },
                    { 5, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3676), null },
                    { 6, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3677), null },
                    { 7, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3678), null },
                    { 8, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3679), null },
                    { 9, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3680), null },
                    { 10, 7, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3681), null },
                    { 1, 9, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3682), null },
                    { 2, 9, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3683), null },
                    { 7, 9, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3684), null },
                    { 8, 9, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3685), null },
                    { 9, 9, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3687), null },
                    { 10, 10, 5, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3688), null }
                });

            migrationBuilder.InsertData(
                table: "SongPlaylist",
                columns: new[] { "PlaylistId", "SongId", "CreatedAt", "ModifiedAt", "SongOrder" },
                values: new object[,]
                {
                    { 1, 1, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3574), null, 1 },
                    { 1, 2, new DateTime(2025, 8, 23, 22, 16, 48, 196, DateTimeKind.Utc).AddTicks(3575), null, 2 }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AlbumArtist_ArtistId",
                table: "AlbumArtist",
                column: "ArtistId");

            migrationBuilder.CreateIndex(
                name: "IX_AlbumGenre_GenreId",
                table: "AlbumGenre",
                column: "GenreId");

            migrationBuilder.CreateIndex(
                name: "IX_ArtistGenre_GenreId",
                table: "ArtistGenre",
                column: "GenreId");

            migrationBuilder.CreateIndex(
                name: "IX_Playlist_UserId",
                table: "Playlist",
                column: "UserId");

            migrationBuilder.CreateIndex(
                name: "IX_SongAlbum_AlbumId",
                table: "SongAlbum",
                column: "AlbumId");

            migrationBuilder.CreateIndex(
                name: "IX_SongArtist_ArtistId",
                table: "SongArtist",
                column: "ArtistId");

            migrationBuilder.CreateIndex(
                name: "IX_SongGenre_GenreId",
                table: "SongGenre",
                column: "GenreId");

            migrationBuilder.CreateIndex(
                name: "IX_SongPlaylist_PlaylistId",
                table: "SongPlaylist",
                column: "PlaylistId");

            migrationBuilder.CreateIndex(
                name: "IX_UserAlbumLike_AlbumId",
                table: "UserAlbumLike",
                column: "AlbumId");

            migrationBuilder.CreateIndex(
                name: "IX_UserAlbumView_AlbumId",
                table: "UserAlbumView",
                column: "AlbumId");

            migrationBuilder.CreateIndex(
                name: "IX_UserArtistLike_ArtistId",
                table: "UserArtistLike",
                column: "ArtistId");

            migrationBuilder.CreateIndex(
                name: "IX_UserArtistView_ArtistId",
                table: "UserArtistView",
                column: "ArtistId");

            migrationBuilder.CreateIndex(
                name: "IX_UserGenreView_GenreId",
                table: "UserGenreView",
                column: "GenreId");

            migrationBuilder.CreateIndex(
                name: "IX_UserRole_RoleId",
                table: "UserRole",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_UserSongLike_SongId",
                table: "UserSongLike",
                column: "SongId");

            migrationBuilder.CreateIndex(
                name: "IX_UserSongView_SongId",
                table: "UserSongView",
                column: "SongId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AlbumArtist");

            migrationBuilder.DropTable(
                name: "AlbumGenre");

            migrationBuilder.DropTable(
                name: "ArtistGenre");

            migrationBuilder.DropTable(
                name: "SongAlbum");

            migrationBuilder.DropTable(
                name: "SongArtist");

            migrationBuilder.DropTable(
                name: "SongGenre");

            migrationBuilder.DropTable(
                name: "SongPlaylist");

            migrationBuilder.DropTable(
                name: "UserAlbumLike");

            migrationBuilder.DropTable(
                name: "UserAlbumView");

            migrationBuilder.DropTable(
                name: "UserArtistLike");

            migrationBuilder.DropTable(
                name: "UserArtistView");

            migrationBuilder.DropTable(
                name: "UserGenreView");

            migrationBuilder.DropTable(
                name: "UserRole");

            migrationBuilder.DropTable(
                name: "UserSongLike");

            migrationBuilder.DropTable(
                name: "UserSongView");

            migrationBuilder.DropTable(
                name: "Playlist");

            migrationBuilder.DropTable(
                name: "Album");

            migrationBuilder.DropTable(
                name: "Artist");

            migrationBuilder.DropTable(
                name: "Genre");

            migrationBuilder.DropTable(
                name: "Role");

            migrationBuilder.DropTable(
                name: "Song");

            migrationBuilder.DropTable(
                name: "User");
        }
    }
}
