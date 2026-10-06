namespace PadmashaliVidyaSetu.Api.Common;

/// <summary>Field-level error. <see cref="Field"/> is a camelCase JSON path, or null for general errors.</summary>
public sealed record ApiError(string? Field, string Message);

/// <summary>Envelope used by every endpoint, success or failure.</summary>
public sealed record ApiResponse<T>(bool Success, string Message, T? Data, IReadOnlyList<ApiError> Errors)
{
    public static ApiResponse<T> Ok(T data, string message = "OK") => new(true, message, data, []);
}

public static class ApiResponse
{
    public static ApiResponse<object> Fail(string message, IReadOnlyList<ApiError>? errors = null) =>
        new(false, message, null, errors ?? []);
}
