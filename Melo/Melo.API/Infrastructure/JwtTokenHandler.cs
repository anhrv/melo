using System.Net.Http.Headers;

namespace Melo.API.Infrastructure
{
	public class JwtTokenHandler : DelegatingHandler
	{
		private readonly IHttpContextAccessor _httpContextAccessor;

		public JwtTokenHandler(IHttpContextAccessor httpContextAccessor)
		{
			_httpContextAccessor = httpContextAccessor;
		}

		protected override async Task<HttpResponseMessage> SendAsync(HttpRequestMessage request, CancellationToken cancellationToken)
		{
			string? token = _httpContextAccessor.HttpContext?.Request.Headers["Authorization"].ToString();

			if (!string.IsNullOrEmpty(token))
			{
				request.Headers.Authorization = new AuthenticationHeaderValue("Bearer", token.Replace("Bearer ", string.Empty));
			}

			return await base.SendAsync(request, cancellationToken);
		}
	}
}
