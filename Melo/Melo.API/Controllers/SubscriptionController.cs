using Melo.Models;
using Melo.Services.Interfaces;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;

namespace Melo.API.Controllers
{
	public class SubscriptionController : CustomControllerBase
	{
		private readonly ISubscriptionService _subscriptionService;

		public SubscriptionController(ISubscriptionService subscriptionService)
		{
			_subscriptionService = subscriptionService;
		}

		[Authorize(Policy = "User")]
		[HttpPost("Create-Subscription")]
		public async Task<IActionResult> CreateSubscription()
		{
			SubscriptionResponse? response = await _subscriptionService.CreateSubscription();
			if (response is null)
			{
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
			return Ok(response);
		}

		[Authorize(Policy = "User")]
		[HttpGet("Confirm-Subscription")]
		public async Task<IActionResult> ConfirmSubscription()
		{
			TokenResponse? response = await _subscriptionService.ConfirmSubscription();
			if (response is null)
			{
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
			return Ok(response);
		}

		[Authorize(Policy = "SubscribedUser")]
		[HttpPost("Cancel-Subscription")]
		public async Task<IActionResult> CancelSubscription()
		{
			TokenResponse? response = await _subscriptionService.CancelSubscription();
			if (response is null)
			{
				return StatusCode(500, ErrorResponse.InternalServerError());
			}
			return Ok(response);
		}
	}
}
