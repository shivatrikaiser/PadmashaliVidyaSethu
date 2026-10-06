using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.RateLimiting;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Services.Locations;
using PadmashaliVidyaSetu.Api.Services.MasterData;

namespace PadmashaliVidyaSetu.Api.Controllers;

[ApiController]
[Authorize(Policy = Policies.Member)]
[Route("api/v1")]
public sealed class MasterDataController(IMasterDataService masterData, IPinCodeLookupService pinCodes) : ControllerBase
{
    /// <summary>Several lists in one call, e.g. <c>?types=temples,genders,member-statuses</c>.</summary>
    [HttpGet("master-data")]
    public async Task<ActionResult<ApiResponse<IReadOnlyDictionary<string, IReadOnlyList<MasterDataItemDto>>>>> GetMany(
        [FromQuery] string? types, CancellationToken ct)
    {
        var requested = (types ?? string.Empty).Split(',', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        if (requested.Length is 0 or > 25)
            throw new RequestValidationException("types", "Specify between 1 and 25 list types.");
        return Ok(ApiResponse<IReadOnlyDictionary<string, IReadOnlyList<MasterDataItemDto>>>.Ok(
            await masterData.GetManyAsync(requested, ct)));
    }

    [HttpGet("master-data/{type}")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MasterDataItemDto>>>> Get(string type, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<MasterDataItemDto>>.Ok(await masterData.GetAsync(type, ct)));

    [HttpGet("locations/countries/{countryId:int}/states")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MasterDataItemDto>>>> States(int countryId, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<MasterDataItemDto>>.Ok(await masterData.GetStatesAsync(countryId, ct)));

    [HttpGet("locations/states/{stateId:int}/districts")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MasterDataItemDto>>>> Districts(int stateId, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<MasterDataItemDto>>.Ok(await masterData.GetDistrictsAsync(stateId, ct)));

    [HttpGet("locations/districts/{districtId:int}/taluks")]
    public async Task<ActionResult<ApiResponse<IReadOnlyList<MasterDataItemDto>>>> Taluks(int districtId, CancellationToken ct) =>
        Ok(ApiResponse<IReadOnlyList<MasterDataItemDto>>.Ok(await masterData.GetTaluksAsync(districtId, ct)));

    /// <summary>PIN code → city/village options, taluk suggestion, district, state, country.</summary>
    [HttpGet("locations/pin-codes/{pinCode}")]
    [EnableRateLimiting(RateLimitPolicies.Lookup)]
    public async Task<ActionResult<ApiResponse<PinCodeLookupResponse>>> PinCode(string pinCode, CancellationToken ct) =>
        Ok(ApiResponse<PinCodeLookupResponse>.Ok(await pinCodes.LookupAsync(pinCode, ct)));
}
