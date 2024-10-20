using EasyNetQ;
using Melo.Models.View;
using Melo.Services.Entities;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

namespace Melo.Services
{
	public class SubscriberService : BackgroundService
	{
		private readonly IBus _bus;
		private readonly IServiceProvider _serviceProvider;
		private readonly IConfiguration _configuration;

		public SubscriberService(IBus bus, IServiceProvider serviceProvider, IConfiguration configuration)
		{
			_bus = bus;
			_serviceProvider = serviceProvider;
			_configuration = configuration;
		}

		protected override async Task ExecuteAsync(CancellationToken stoppingToken)
		{
			await _bus.PubSub.SubscribeAsync<ViewRequest>(_configuration["RabbitMQ:SubscriptionId"], async message =>
			{
				using (var scope = _serviceProvider.CreateScope())
				{
					var _context = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();

					var song = await _context.Songs.Include(s => s.SongGenres)
														.ThenInclude(sg => sg.Genre)
													 .Include(s => s.SongArtists)
														.ThenInclude(sa => sa.Artist)
													 .Include(s => s.SongAlbums)
														.ThenInclude(sa => sa.Album)
													 .FirstOrDefaultAsync(s => s.Id == message.SongId);
					if (song is null)
					{
						return;
					}

					song.ViewCount++;

					var userSongView = await _context.UserSongViews.FirstOrDefaultAsync(usv => usv.UserId == message.UserId && usv.SongId == message.SongId);

					if (userSongView is null)
					{
						userSongView = new UserSongView() { UserId = message.UserId, SongId = message.SongId, CreatedAt = DateTime.UtcNow, Count = 0 };
						await _context.AddAsync(userSongView);
					}

					userSongView.ModifiedAt = DateTime.UtcNow;
					userSongView.Count++;

					var userGenreIds = song.SongGenres.Select(sg => sg.GenreId).ToHashSet();
					var userArtistIds = song.SongArtists.Select(sa => sa.ArtistId).ToHashSet();
					var userAlbumIds = song.SongAlbums.Select(sa => sa.AlbumId).ToHashSet();

					var userGenreViews = await _context.UserGenreViews
						.Where(ugv => ugv.UserId == message.UserId && userGenreIds.Contains(ugv.GenreId))
						.ToListAsync();

					var userArtistViews = await _context.UserArtistViews
						.Where(uav => uav.UserId == message.UserId && userArtistIds.Contains(uav.ArtistId))
						.ToListAsync();

					var userAlbumViews = await _context.UserAlbumViews
						.Where(uav => uav.UserId == message.UserId && userAlbumIds.Contains(uav.AlbumId))
						.ToListAsync();

					foreach (var songGenre in song.SongGenres)
					{
						songGenre.Genre.ViewCount++;

						var userGenreView = userGenreViews.FirstOrDefault(ugv => ugv.GenreId == songGenre.GenreId);
						if (userGenreView is null)
						{
							userGenreView = new UserGenreView
							{
								UserId = message.UserId,
								GenreId = songGenre.GenreId,
								CreatedAt = DateTime.UtcNow,
								Count = 0
							};
							await _context.AddAsync(userGenreView);
						}

						userGenreView.ModifiedAt = DateTime.UtcNow;
						userGenreView.Count++;

					}

					foreach (var songArtist in song.SongArtists)
					{
						songArtist.Artist.ViewCount++;

						var userArtistView = userArtistViews.FirstOrDefault(uav => uav.ArtistId == songArtist.ArtistId);
						if (userArtistView is null)
						{
							userArtistView = new UserArtistView
							{
								UserId = message.UserId,
								ArtistId = songArtist.ArtistId,
								CreatedAt = DateTime.UtcNow,
								Count = 0
							};
							await _context.AddAsync(userArtistView);
						}

						userArtistView.ModifiedAt = DateTime.UtcNow;
						userArtistView.Count++;

					}

					foreach (var songAlbum in song.SongAlbums)
					{
						songAlbum.Album.ViewCount++;

						var userAlbumView = userAlbumViews.FirstOrDefault(uav => uav.AlbumId == songAlbum.AlbumId);
						if (userAlbumView is null)
						{
							userAlbumView = new UserAlbumView
							{
								UserId = message.UserId,
								AlbumId = songAlbum.AlbumId,
								CreatedAt = DateTime.UtcNow,
								Count = 0
							};
							await _context.AddAsync(userAlbumView);
						}

						userAlbumView.ModifiedAt = DateTime.UtcNow;
						userAlbumView.Count++;

					}

					await _context.SaveChangesAsync();
				}
			});

			await Task.CompletedTask;
		}
	}
}
