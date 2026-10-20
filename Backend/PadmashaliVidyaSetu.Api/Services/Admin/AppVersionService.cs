using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Settings;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface IAppVersionService
{
    Task<AppVersionDto> GetAsync(string? platform, CancellationToken ct);
}

/// <summary>The current app release per platform (single row each), read by the app on every screen.</summary>
public sealed class AppVersionService(AppDbContext db) : IAppVersionService
{
    public async Task<AppVersionDto> GetAsync(string? platform, CancellationToken ct)
    {
        var key = platform?.Trim().ToLowerInvariant();
        if (key is not (AppVersion.Android or AppVersion.Ios))
            throw new RequestValidationException([new ApiError("platform", "Use 'android' or 'ios'.")]);

        return await db.AppVersions.AsNoTracking()
                   .Where(v => v.Platform == key)
                   .Select(v => new AppVersionDto(v.Platform, v.LatestVersion, v.IsMandatory, v.StoreUrl))
                   .SingleOrDefaultAsync(ct)
               ?? throw new NotFoundException("No version is configured for this platform.");
    }
}
