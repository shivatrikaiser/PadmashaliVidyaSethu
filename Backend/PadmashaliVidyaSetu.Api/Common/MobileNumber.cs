using System.Text.RegularExpressions;

namespace PadmashaliVidyaSetu.Api.Common;

/// <summary>
/// Mobile number normalisation, stored in E.164 form (+CCNNNN...). Indian mobile numbers (10 digits starting 6-9,
/// +91) are the default and may be entered without the country code. Numbers in other countries must be entered with
/// it ("+971 50 123 4567" or "00971..."); they are checked for E.164 shape only (8-15 digits).
/// </summary>
public static partial class MobileNumber
{
    public const string IndiaCountryCode = "91";

    [GeneratedRegex(@"^[6-9]\d{9}$")]
    private static partial Regex IndianMobile();

    [GeneratedRegex(@"^[1-9]\d{7,14}$")]
    private static partial Regex E164Digits();

    /// <summary>
    /// Accepts "9876543210", "+919876543210", "91 98765 43210", "098765-43210" (India) and
    /// "+971501234567", "00971 50 123 4567" (other countries).
    /// </summary>
    public static bool TryNormalize(string? input, out string e164)
    {
        e164 = string.Empty;
        if (string.IsNullOrWhiteSpace(input)) return false;

        var trimmed = input.Trim();
        var digits = new string(trimmed.Where(char.IsDigit).ToArray());
        var withCountryCode = trimmed.StartsWith('+') || trimmed.StartsWith("00", StringComparison.Ordinal);
        if (trimmed.StartsWith("00", StringComparison.Ordinal)) digits = digits[2..];

        if (withCountryCode && !digits.StartsWith(IndiaCountryCode, StringComparison.Ordinal))
        {
            if (!E164Digits().IsMatch(digits)) return false;
            e164 = "+" + digits;
            return true;
        }

        if (digits.Length == 12 && digits.StartsWith(IndiaCountryCode, StringComparison.Ordinal)) digits = digits[2..];
        else if (digits.Length == 11 && digits.StartsWith('0')) digits = digits[1..];

        if (!IndianMobile().IsMatch(digits)) return false;
        e164 = "+" + IndiaCountryCode + digits;
        return true;
    }

    /// <summary>True for an Indian (+91) number in E.164 form.</summary>
    public static bool IsIndian(string e164) => e164.StartsWith("+" + IndiaCountryCode, StringComparison.Ordinal);

    /// <summary>For logs and UI: +91******3210.</summary>
    public static string Mask(string e164) =>
        e164.Length <= 4 ? "****" : e164[..3] + new string('*', e164.Length - 7) + e164[^4..];
}
