using Melo.Models;
using Microsoft.AspNetCore.Diagnostics;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Infrastructure
{
	public class ExceptionHandler : IExceptionHandler
	{
		private readonly ILogger<ExceptionHandler> _logger;

        public ExceptionHandler(ILogger<ExceptionHandler> logger)
        {
			_logger = logger;
        }

        public async ValueTask<bool> TryHandleAsync(HttpContext httpContext, Exception exception, CancellationToken cancellationToken)
		{
			_logger.LogError(exception, exception.Message);

			ProblemDetails response = ErrorResponse.InternalServerError();

			httpContext.Response.StatusCode = (int)response.Status!;

			await httpContext.Response.WriteAsJsonAsync(response, cancellationToken);

			return true;
		}
	}
}
