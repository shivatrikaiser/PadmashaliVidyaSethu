namespace PadmashaliVidyaSetu.Api.Common;

public static class ClockExtensions
{
    private static readonly TimeSpan IndiaOffset = TimeSpan.FromHours(5.5);

    /// <summary>Today's calendar date in India (IST), used for age calculation.</summary>
    public static DateOnly TodayInIndia(this TimeProvider clock) =>
        DateOnly.FromDateTime(clock.GetUtcNow().ToOffset(IndiaOffset).DateTime);
}

public static class TextExtensions
{
    /// <summary>Trims and collapses internal whitespace. Returns empty string for null.</summary>
    public static string Tidy(this string? value) =>
        string.Join(' ', (value ?? string.Empty).Split((char[]?)null, StringSplitOptions.RemoveEmptyEntries));
}
