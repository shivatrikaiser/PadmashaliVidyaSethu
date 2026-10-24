using System.Threading.RateLimiting;
using Microsoft.AspNetCore.RateLimiting;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Middleware;

namespace PadmashaliVidyaSetu.Api.Configuration;

public static class RateLimitPolicies
{
    public const string Verification = nameof(Verification);
    public const string Auth = nameof(Auth);
    public const string Lookup = nameof(Lookup);
    public const string Enquiry = nameof(Enquiry);
}

/// <summary>Per-client-IP limits. Per-mobile-number limits for verification codes are enforced in AuthService.</summary>
public class RateLimitingOptions
{
    public const string Section = "RateLimiting";
    public int VerificationPermitLimit { get; set; } = 10;
    public int VerificationWindowSeconds { get; set; } = 600;
    public int AuthPermitLimit { get; set; } = 30;
    public int LookupPermitLimit { get; set; } = 30;
    public int GlobalPermitLimit { get; set; } = 300;

    /// <summary>Website enquiries per client IP per hour.</summary>
    public int EnquiryPermitLimit { get; set; } = 5;
}

public static class RateLimitingSetup
{
    public static IServiceCollection AddPvsRateLimiting(this IServiceCollection services)
    {
        services.AddRateLimiter(options =>
        {
            options.GlobalLimiter = PartitionedRateLimiter.Create<HttpContext, string>(ctx =>
                RateLimitPartition.GetFixedWindowLimiter(ClientKey(ctx), _ => Window(Limits(ctx).GlobalPermitLimit, 60)));

            options.AddPolicy(RateLimitPolicies.Verification, ctx =>
                RateLimitPartition.GetFixedWindowLimiter(ClientKey(ctx), _ =>
                    Window(Limits(ctx).VerificationPermitLimit, Limits(ctx).VerificationWindowSeconds)));
            options.AddPolicy(RateLimitPolicies.Auth, ctx =>
                RateLimitPartition.GetFixedWindowLimiter(ClientKey(ctx), _ => Window(Limits(ctx).AuthPermitLimit, 60)));
            options.AddPolicy(RateLimitPolicies.Enquiry, ctx =>
                RateLimitPartition.GetFixedWindowLimiter(ClientKey(ctx), _ => Window(Limits(ctx).EnquiryPermitLimit, 3600)));
            options.AddPolicy(RateLimitPolicies.Lookup, ctx =>
                RateLimitPartition.GetFixedWindowLimiter(ClientKey(ctx), _ => Window(Limits(ctx).LookupPermitLimit, 60)));

            options.OnRejected = async (context, ct) =>
            {
                if (context.Lease.TryGetMetadata(MetadataName.RetryAfter, out var retryAfter))
                    context.HttpContext.Response.Headers.RetryAfter = ((int)retryAfter.TotalSeconds).ToString();
                await ExceptionHandlingMiddleware.WriteAsync(context.HttpContext, StatusCodes.Status429TooManyRequests,
                    ApiResponse.Fail("Too many requests. Please wait a moment and try again."));
            };
        });
        return services;
    }

    private static RateLimitingOptions Limits(HttpContext ctx) =>
        ctx.RequestServices.GetRequiredService<IOptions<RateLimitingOptions>>().Value;

    private static string ClientKey(HttpContext ctx) => ctx.Connection.RemoteIpAddress?.ToString() ?? "unknown";

    private static FixedWindowRateLimiterOptions Window(int permits, int seconds) => new()
    {
        PermitLimit = permits,
        Window = TimeSpan.FromSeconds(seconds),
        QueueLimit = 0,
    };
}
