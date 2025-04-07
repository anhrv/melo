using DotNetEnv;
using EasyNetQ;
using FluentValidation;
using FluentValidation.AspNetCore;
using Mapster;
using Melo.API.Authorization;
using Melo.API.Infrastructure;
using Melo.Models;
using Melo.Services;
using Melo.Services.Interfaces;
using Melo.Services.Mappings;
using Melo.Services.Validators;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;
using Stripe;

namespace Melo.API
{
    public class Program
	{
		public static async Task Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			Env.Load("../.env");

			StripeConfiguration.ApiKey = Environment.GetEnvironmentVariable("STRIPE_SECRET_KEY");

			var connectionString = Environment.GetEnvironmentVariable("DB_CONNECTION_STRING");
			builder.Services.AddDbContext<ApplicationDbContext>(options => options.UseSqlServer(connectionString));

			builder.Services.AddScoped<ISongService, SongService>();
			builder.Services.AddScoped<IArtistService, ArtistService>();
			builder.Services.AddScoped<IAlbumService, AlbumService>();
			builder.Services.AddScoped<IGenreService, GenreService>();
			builder.Services.AddScoped<IPlaylistService, PlaylistService>();
			builder.Services.AddScoped<ISongLikeService, SongLikeService>();
			builder.Services.AddScoped<IArtistLikeService, ArtistLikeService>();
			builder.Services.AddScoped<IAlbumLikeService, AlbumLikeService>();
			builder.Services.AddScoped<IRecommendationService, RecommendationService>();
			builder.Services.AddScoped<IModelTrainingService, ModelTrainingService>();
			builder.Services.AddScoped<ISubscriptionService, Melo.Services.SubscriptionService>();
			builder.Services.AddScoped<IUserService, UserService>();
			builder.Services.AddScoped<IRoleService, RoleService>();
			builder.Services.AddScoped<IAuthService, AuthService>();
			builder.Services.AddScoped<IJWTService, JWTService>();
			builder.Services.AddScoped<JwtTokenHandler>();
			builder.Services.AddScoped<Stripe.SubscriptionService>();
			builder.Services.AddScoped<CustomerService>();
			builder.Services.AddScoped<SubscriptionUtility>();
			builder.Services.AddScoped<IAuthorizationHandler, SubscriptionActiveHandler>();
			builder.Services.AddScoped<IAuthorizationHandler, AdminOrSubscribedUserHandler>();
			builder.Services.AddScoped<IAuthorizationMiddlewareResultHandler, CustomAuthorizationMiddlewareResultHandler>();

			builder.Services.AddSingleton(RabbitHutch.CreateBus(Environment.GetEnvironmentVariable("RABBITMQ_HOST_STRING")));
			builder.Services.AddHostedService<SubscriberService>();
			builder.Services.AddHostedService<ModelTrainingBackgroundService>();

			builder.Services.AddHttpClient<IFileService, Melo.Services.FileService>(httpClient =>
			{
				httpClient.BaseAddress = new Uri(Environment.GetEnvironmentVariable("FILE_SERVER_BASE_URL"));
				
			})
			.AddHttpMessageHandler<JwtTokenHandler>()
			.ConfigurePrimaryHttpMessageHandler(() =>
			{
				return new SocketsHttpHandler
				{
					PooledConnectionLifetime = TimeSpan.FromMinutes(5)
				};
			})
			.SetHandlerLifetime(Timeout.InfiniteTimeSpan);

			builder.Services.AddExceptionHandler<ExceptionHandler>();
			builder.Services.AddProblemDetails();

			builder.Services.AddHttpContextAccessor();

			builder.Services.AddFluentValidationAutoValidation();
			builder.Services.AddValidatorsFromAssemblyContaining<UserInsertValidator>();
			builder.Services.AddValidatorsFromAssemblyContaining<UserUpdateValidator>();
			builder.Services.AddValidatorsFromAssemblyContaining<RegisterRequestValidator>();
			builder.Services.AddValidatorsFromAssemblyContaining<AccountUpdateValidator>();
			builder.Services.AddValidatorsFromAssemblyContaining<PasswordUpdateValidator>();

			builder.Services.AddMapster();
			MappingConfig.RegisterMappings();

			builder.Services.AddControllers(options => {
				var policy = new AuthorizationPolicyBuilder().RequireAuthenticatedUser().Build();
				options.Filters.Add(new AuthorizeFilter(policy));
			});

			builder.Services.AddEndpointsApiExplorer();
			builder.Services.AddSwaggerGen(c =>
			{
				var jwtSecurityScheme = new OpenApiSecurityScheme
				{
					Scheme = "bearer",
					BearerFormat = "JWT",
					Name = "Authorization",
					In = ParameterLocation.Header,
					Type = SecuritySchemeType.Http,
					Description = "Put your JWT Bearer token in textbox below",

					Reference = new OpenApiReference
					{
						Id = JwtBearerDefaults.AuthenticationScheme,
						Type = ReferenceType.SecurityScheme
					}
				};

				c.AddSecurityDefinition(jwtSecurityScheme.Reference.Id, jwtSecurityScheme);

				c.AddSecurityRequirement(new OpenApiSecurityRequirement{ { jwtSecurityScheme, Array.Empty<string>() } });
			});

			builder.Services.AddAuthentication(options => {
				options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
				options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
			})
			.AddJwtBearer(options =>
			{
				options.MapInboundClaims = false;
				options.TokenValidationParameters = new TokenValidationParameters()
				{
					ValidateAudience = true,
					ValidAudience = Environment.GetEnvironmentVariable("JWT_AUDIENCE"),
					ValidateIssuer = true,
					ValidIssuer = Environment.GetEnvironmentVariable("JWT_ISSUER"),
					ValidateLifetime = true,
					ValidateIssuerSigningKey = true,
					IssuerSigningKey = new SymmetricSecurityKey(System.Text.Encoding.UTF8.GetBytes(Environment.GetEnvironmentVariable("JWT_KEY"))),
					ClockSkew = TimeSpan.Zero
				};
				options.Events = new JwtBearerEvents
				{
					OnChallenge = context =>
					{
						context.HandleResponse();
						context.Response.StatusCode = StatusCodes.Status401Unauthorized;
						context.Response.ContentType = "application/json";
						ProblemDetails response = ErrorResponse.Unauthorized();
						return context.Response.WriteAsJsonAsync(response);
					},
					OnForbidden = context =>
					{
						context.Response.StatusCode = StatusCodes.Status403Forbidden;
						context.Response.ContentType = "application/json";
						ProblemDetails response = ErrorResponse.Forbidden();
						return context.Response.WriteAsJsonAsync(response);
					}
				};
			});

			builder.Services.AddAuthorization(options => {
				options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
				options.AddPolicy("User", policy => policy.RequireRole("User"));
				options.AddPolicy("SubscribedUser", policy =>
				{
					policy.RequireRole("User");
					policy.AddRequirements(new SubscriptionActiveRequirement());
				});
				options.AddPolicy("AdminOrSubscribedUser", policy => policy.AddRequirements(new AdminOrSubscribedUserRequirement()));
			});

			var app = builder.Build();

			if (app.Environment.IsDevelopment())
			{
				app.UseSwagger();
				app.UseSwaggerUI();
			}

			app.UseCors(options => options
				.SetIsOriginAllowed(x => _ = true)
				.AllowAnyMethod()
				.AllowAnyHeader()
				.AllowCredentials()
			);

			app.UseHsts();
			app.UseHttpsRedirection();

			app.UseExceptionHandler();

			app.UseAuthentication();
			app.UseAuthorization();

			app.MapControllers();

			using (var scope = app.Services.CreateScope())
			{
				var dbContext = scope.ServiceProvider.GetRequiredService<ApplicationDbContext>();
				if (!dbContext.Database.CanConnect() || dbContext.Database.GetPendingMigrations().Any())
				{
					dbContext.Database.Migrate();
				}
			}

			app.Run();
		}
	}
}
