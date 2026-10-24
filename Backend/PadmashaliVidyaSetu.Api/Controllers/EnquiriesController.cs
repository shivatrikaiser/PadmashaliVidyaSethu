using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Website;

namespace PadmashaliVidyaSetu.Api.Controllers;

/// <summary>
/// The VidyaSethu website's enquiry forms (contact page and "For organizations"). One endpoint for every
/// organization; each enquiry is emailed to the support inbox. Anonymous, rate-limited per IP.
/// </summary>
[ApiController]
[AllowAnonymous]
[Route("api/v1/enquiries")]
public sealed class EnquiriesController(IEnquiryService enquiries) : ControllerBase
{
    /// <summary>Returns 200 only once the enquiry email was accepted by the mail server.</summary>
    [HttpPost]
    [EnableRateLimiting(RateLimitPolicies.Enquiry)]
    public async Task<ActionResult<ApiResponse<object>>> Submit(EnquiryRequest request, CancellationToken ct)
    {
        await enquiries.SubmitAsync(request, ct);
        return Ok(ApiResponse<object>.Ok(new { Received = true }, "Thank you - your enquiry has been sent."));
    }
}
