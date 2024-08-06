using Mapster;
using Melo.Services;
using Melo.Services.Interfaces;
using Microsoft.EntityFrameworkCore;

namespace Melo.API
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);
			var config = builder.Configuration;

			builder.Services.AddScoped<IGenreService, GenreService>();

			builder.Services.AddControllers();

			builder.Services.AddDbContext<ApplicationDbContext>(options => options.UseSqlServer(config.GetConnectionString("DefaultConnection")));

			builder.Services.AddMapster();

			builder.Services.AddEndpointsApiExplorer();
			builder.Services.AddSwaggerGen();

			var app = builder.Build();

			if (app.Environment.IsDevelopment())
			{
				app.UseSwagger();
				app.UseSwaggerUI();
			}

			app.UseHttpsRedirection();

			app.MapControllers();

			app.Run();
		}
	}
}
