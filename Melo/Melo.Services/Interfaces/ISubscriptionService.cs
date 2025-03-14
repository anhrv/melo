using Melo.Models;

namespace Melo.Services.Interfaces
{
	public interface ISubscriptionService
	{
		Task<SubscriptionResponse?> CreateSubscription();
		Task<TokenResponse?> ConfirmSubscription();
		Task<TokenResponse?> CancelSubscription();
	}
}
