using System.Security.Claims;
using Microsoft.IdentityModel.JsonWebTokens;

namespace PadmashaliVidyaSetu.Api.Authentication;

public interface ICurrentUserService
{
    int? AccountId { get; }
    bool IsInRole(string roleCode);
    string? IpAddress { get; }

    /// <summary>Value written to CreatedBy / ModifiedBy: "account:{id}" or "system".</summary>
    string AuditName { get; }
}

public sealed class HttpCurrentUserService(IHttpContextAccessor accessor) : ICurrentUserService
{
    private ClaimsPrincipal? User => accessor.HttpContext?.User;

    public int? AccountId =>
        int.TryParse(User?.FindFirstValue(JwtRegisteredClaimNames.Sub) ?? User?.FindFirstValue(ClaimTypes.NameIdentifier), out var id)
            ? id
            : null;

    public bool IsInRole(string roleCode) => User?.IsInRole(roleCode) ?? false;

    public string? IpAddress => accessor.HttpContext?.Connection.RemoteIpAddress?.ToString();

    public string AuditName => AccountId is { } id ? $"account:{id}" : "system";
}

/// <summary>Used outside HTTP requests (design-time tooling, background work).</summary>
public sealed class SystemCurrentUserService : ICurrentUserService
{
    public int? AccountId => null;
    public bool IsInRole(string roleCode) => false;
    public string? IpAddress => null;
    public string AuditName => "system";
}

public static class CurrentUserExtensions
{
    public static int RequireAccountId(this ICurrentUserService user) =>
        user.AccountId ?? throw new Common.UnauthorizedException("Please sign in again.");
}
