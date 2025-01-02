
using DotNetEnv;
using Melo.Models;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Authorization;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi.Models;

namespace Melo.Files
{
	public class Program
	{
		public static void Main(string[] args)
		{
			var builder = WebApplication.CreateBuilder(args);

			Env.Load("../.env");

			builder.Services.AddMemoryCache();

			builder.Services.AddControllers(options =>
			{
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

				c.AddSecurityRequirement(new OpenApiSecurityRequirement { { jwtSecurityScheme, Array.Empty<string>() } });
			});

			builder.Services.AddAuthentication(options =>
			{
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

			builder.Services.AddAuthorization(options =>
			{
				options.AddPolicy("Admin", policy => policy.RequireRole("Admin"));
				options.AddPolicy("User", policy => policy.RequireRole("User"));
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

			app.UseAuthentication();
			app.UseAuthorization();

			app.MapControllers();

			app.Run();
		}
	}
}
