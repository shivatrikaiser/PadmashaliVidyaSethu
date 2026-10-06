using System.Text.RegularExpressions;

namespace PadmashaliVidyaSetu.Api.Common;

/// <summary>
/// Mobile number normalisation. V1 accepts Indian mobile numbers only (10 digits starting 6-9),
/// stored in E.164 form (+91XXXXXXXXXX). See Docs/Architecture.md for the plan to support other countries.
/// </summary>
public static partial class MobileNumber
{
    [GeneratedRegex(@"^[6-9]\d{9}$")]
    private static partial Regex IndianMobile();

    /// <summary>Accepts "9876543210", "+919876543210", "91 98765 43210", "098765-43210".</summary>
    public static bool TryNormalize(string? input, out string e164)
    {
        e164 = string.Empty;
        if (string.IsNullOrWhiteSpace(input)) return false;

        var digits = new string(input.Where(char.IsDigit).ToArray());
        if (digits.Length == 12 && digits.StartsWith("91")) digits = digits[2..];
        else if (digits.Length == 11 && digits.StartsWith('0')) digits = digits[1..];

        if (!IndianMobile().IsMatch(digits)) return false;
        e164 = "+91" + digits;
        return true;
    }

    /// <summary>For logs and UI: +91******3210.</summary>
    public static string Mask(string e164) =>
        e164.Length <= 4 ? "****" : e164[..3] + new string('*', e164.Length - 7) + e164[^4..];
}
