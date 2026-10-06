namespace PadmashaliVidyaSetu.Api.Common;

/// <summary>
/// Expected, user-facing failures. The message is safe to show to the user.
/// Anything that is not an <see cref="AppException"/> is treated as an internal error and its details are hidden.
/// </summary>
public abstract class AppException(int statusCode, string message, IReadOnlyList<ApiError>? errors = null)
    : Exception(message)
{
    public int StatusCode { get; } = statusCode;
    public IReadOnlyList<ApiError> Errors { get; } = errors ?? [];
}

public sealed class RequestValidationException(IReadOnlyList<ApiError> errors, string message = "Please correct the highlighted fields.")
    : AppException(StatusCodes.Status400BadRequest, message, errors)
{
    public RequestValidationException(string field, string message)
        : this([new ApiError(field, message)]) { }
}

public sealed class NotFoundException(string message) : AppException(StatusCodes.Status404NotFound, message);

public sealed class ForbiddenException(string message = "You do not have access to this information.")
    : AppException(StatusCodes.Status403Forbidden, message);

public sealed class UnauthorizedException(string message) : AppException(StatusCodes.Status401Unauthorized, message);

public sealed class ConflictException(string message) : AppException(StatusCodes.Status409Conflict, message);

public sealed class BusinessRuleException(string message) : AppException(StatusCodes.Status422UnprocessableEntity, message);

public sealed class TooManyRequestsException(string message, int retryAfterSeconds)
    : AppException(StatusCodes.Status429TooManyRequests, message)
{
    public int RetryAfterSeconds { get; } = retryAfterSeconds;
}

public sealed class ServiceUnavailableException(string message) : AppException(StatusCodes.Status503ServiceUnavailable, message);
