using Mapster;
using Melo.API.Infrastructure;
using Melo.Services;
using Melo.Services.Interfaces;
using Melo.Services.Mapping;
using Microsoft.EntityFrameworkCore;

namespace Melo.API
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			var connectionString = builder.Configuration.GetConnectionString("DefaultConnection");
			builder.Services.AddDbContext<ApplicationDbContext>(options => options.UseSqlServer(connectionString));

			builder.Services.AddScoped<ISongService, SongService>();
			builder.Services.AddScoped<IArtistService, ArtistService>();
			builder.Services.AddScoped<IGenreService, GenreService>();

			builder.Services.AddExceptionHandler<ExceptionHandler>();
			builder.Services.AddProblemDetails();

			builder.Services.AddControllers();

			builder.Services.AddMapster();
			MappingConfig.RegisterMappings();

			builder.Services.AddEndpointsApiExplorer();
			builder.Services.AddSwaggerGen();

			var app = builder.Build();

			if (app.Environment.IsDevelopment())
			{
				app.UseSwagger();
				app.UseSwaggerUI();
			}

			app.UseHttpsRedirection();

			app.UseExceptionHandler();

			app.MapControllers();

			app.Run();
		}
	}
}
