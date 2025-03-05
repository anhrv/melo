using Melo.Models;
using Melo.Services.Entities;

namespace Melo.Services.Interfaces
{
	public interface ISubscriptionService
	{
		Task<SessionResponse?> CreateCheckoutSession();
		Task<User?> ConfirmSubscription(SessionRequest request);
	}
}
