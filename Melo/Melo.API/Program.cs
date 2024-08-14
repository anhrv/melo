using FluentValidation;
using FluentValidation.AspNetCore;
using Mapster;
using Melo.API.Infrastructure;
using Melo.Services;
using Melo.Services.Interfaces;
using Melo.Services.Mapping;
using Melo.Services.Validators;
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
			builder.Services.AddScoped<IAlbumService, AlbumService>();
			builder.Services.AddScoped<IGenreService, GenreService>();
			builder.Services.AddScoped<IUserService, UserService>();

			builder.Services.AddExceptionHandler<ExceptionHandler>();
			builder.Services.AddProblemDetails();

			builder.Services.AddHttpContextAccessor();
			builder.Services.AddFluentValidationAutoValidation();
			builder.Services.AddValidatorsFromAssemblyContaining<UserInsertValidator>();
			builder.Services.AddValidatorsFromAssemblyContaining<UserUpdateValidator>();

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
