using PadmashaliVidyaSetu.Api.Configuration;

namespace PadmashaliVidyaSetu.Api.Middleware;

/// <summary>Conservative headers for a JSON-only API.</summary>
public sealed class SecurityHeadersMiddleware(RequestDelegate next)
{
    // Swagger UI is an HTML page: it needs its own scripts, styles (some inline), data: images and calls to this API.
    private const string SwaggerUiPolicy =
        "default-src 'none'; script-src 'self'; style-src 'self' 'unsafe-inline'; img-src 'self' data:; " +
        "connect-src 'self'; frame-ancestors 'none'; base-uri 'none'; form-action 'none'";

    public Task InvokeAsync(HttpContext context)
    {
        var headers = context.Response.Headers;
        headers.XContentTypeOptions = "nosniff";
        headers.XFrameOptions = "DENY";
        headers["Referrer-Policy"] = "no-referrer";
        headers.ContentSecurityPolicy = context.Request.Path.StartsWithSegments(SwaggerSettings.UiPath)
            ? SwaggerUiPolicy
            : "default-src 'none'; frame-ancestors 'none'";
        headers.CacheControl = "no-store";
        headers["Permissions-Policy"] = "camera=(), microphone=(), geolocation=()";
        return next(context);
    }
}
