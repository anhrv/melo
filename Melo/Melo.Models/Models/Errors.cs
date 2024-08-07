using Microsoft.AspNetCore.Mvc;
using System.Net;

namespace Melo.Models
{
	public static class Errors
    {
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
