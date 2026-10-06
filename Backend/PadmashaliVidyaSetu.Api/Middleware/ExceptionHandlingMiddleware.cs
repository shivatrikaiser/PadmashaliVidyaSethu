using System.Text.Json;
using PadmashaliVidyaSetu.Api.Common;

namespace PadmashaliVidyaSetu.Api.Middleware;

/// <summary>
/// Converts every exception into the standard <c>{ success, message, errors }</c> envelope.
/// Expected errors (<see cref="AppException"/>) pass their user-safe message through; anything else is logged with
/// full detail on the server and answered with a generic message plus a trace id — never a stack trace or SQL error.
/// </summary>
public sealed class ExceptionHandlingMiddleware(RequestDelegate next, ILogger<ExceptionHandlingMiddleware> logger)
{
    public static readonly JsonSerializerOptions JsonOptions = new(JsonSerializerDefaults.Web);

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            await next(context);
        }
        catch (OperationCanceledException) when (context.RequestAborted.IsCancellationRequested)
        {
            // Client went away; nothing to send.
        }
        catch (AppException ex)
        {
            if (ex.StatusCode >= 500)
                logger.LogError(ex, "Request failed: {Message}", ex.Message);
            else
                logger.LogInformation("Request rejected ({StatusCode}): {Message}", ex.StatusCode, ex.Message);

            if (ex is TooManyRequestsException tooMany)
                context.Response.Headers.RetryAfter = tooMany.RetryAfterSeconds.ToString();

            await WriteAsync(context, ex.StatusCode, ApiResponse.Fail(ex.Message, ex.Errors));
        }
        catch (Exception ex)
        {
            logger.LogError(ex, "Unhandled exception for {Method} {Path}", context.Request.Method, context.Request.Path);
            await WriteAsync(context, StatusCodes.Status500InternalServerError, ApiResponse.Fail(
                "Unable to complete the request. Please try again later.",
                [new ApiError(null, $"Reference: {context.TraceIdentifier}")]));
        }
    }

    public static async Task WriteAsync(HttpContext context, int statusCode, ApiResponse<object> body)
    {
        if (context.Response.HasStarted) return;
        // Not Response.Clear(): that would also drop headers already set (security headers, Retry-After).
        context.Response.StatusCode = statusCode;
        context.Response.ContentType = "application/json; charset=utf-8";
        await JsonSerializer.SerializeAsync(context.Response.Body, body, JsonOptions);
    }
}
