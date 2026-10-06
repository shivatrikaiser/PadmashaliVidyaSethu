using Microsoft.AspNetCore.Authorization;
using PadmashaliVidyaSetu.Api.Entities.Accounts;

namespace PadmashaliVidyaSetu.Api.Authorization;

/// <summary>
/// Policy names. Controllers depend on policies, never on role names directly, so new coordinator roles can be
/// mapped to existing policies in one place.
/// </summary>
public static class Policies
{
    /// <summary>Any signed-in account (member self-service).</summary>
    public const string Member = nameof(Member);

    /// <summary>Administrative portal access.</summary>
    public const string Admin = nameof(Admin);

    /// <summary>Access to sensitive personal data (disability details). Deliberately narrower than Admin.</summary>
    public const string ViewSensitiveData = nameof(ViewSensitiveData);

    public static void AddPvsPolicies(this AuthorizationOptions options)
    {
        options.AddPolicy(Member, p => p.RequireAuthenticatedUser());
        options.AddPolicy(Admin, p => p.RequireRole(RoleCodes.Admin, RoleCodes.SuperAdmin));
        options.AddPolicy(ViewSensitiveData, p => p.RequireRole(RoleCodes.SuperAdmin));
        options.FallbackPolicy = options.GetPolicy(Member);
    }
}
