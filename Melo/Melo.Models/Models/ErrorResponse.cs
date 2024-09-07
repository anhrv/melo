using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.Models
{
	public static class ErrorResponse
    {
		public static ProblemDetails BadRequest(string message = "Input is not valid") =>
		CreateResponse((int)HttpStatusCode.BadRequest,
						"Bad Request",
						"https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.1",
						[message]);

		public static ProblemDetails Unauthorized(string message = "You need to be logged in for this action") =>
		CreateResponse((int)HttpStatusCode.Unauthorized,
						"Unauthorized",
						"https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.2",
						[message]);

		public static ProblemDetails Forbidden(string message = "You do not have permission for this action") =>
		CreateResponse((int)HttpStatusCode.Forbidden,
						"Forbidden",
						"https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.4",
						[message]);

		public static ProblemDetails NotFound(string message = "Object does not exist") =>
        CreateResponse((int)HttpStatusCode.NotFound,
                       "Not Found",
                       "https://datatracker.ietf.org/doc/html/rfc9110#section-15.5.5",
                       [message]);

        public static ProblemDetails InternalServerError(string message = "Something went wrong") =>
        CreateResponse((int)HttpStatusCode.InternalServerError,
                        "Internal Server Error",
                        "https://datatracker.ietf.org/doc/html/rfc9110#section-15.6.1",
                        [message]);

		private static ProblemDetails CreateResponse(int status, string title, string type, List<string> message)
        {
            Dictionary<string, List<string>> errors = new()
			{
                { "error", message }
            };

            ProblemDetails response = new()
			{
                Status = status,
                Title = title,
                Type = type,
            };

            response.Extensions["errors"] = errors;

            return response;
        }
    }
}
