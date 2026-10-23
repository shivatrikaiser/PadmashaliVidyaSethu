using System.Text.RegularExpressions;

namespace PadmashaliVidyaSetu.Api.Common;

/// <summary>
/// Email address normalisation (trimmed, lower case). Asked for alongside a mobile number outside India, so the
/// verification code goes to both the WhatsApp number and the email address.
/// </summary>
public static partial class EmailAddress
{
    public const int MaxLength = 254;

    // Pragmatic shape check (local@domain.tld); the real test is that the code arrives.
    [GeneratedRegex(@"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~\-]+@[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9\-]{0,61}[A-Za-z0-9])?)+$")]
    private static partial Regex Shape();

    public static bool TryNormalize(string? input, out string email)
    {
        email = string.Empty;
        if (string.IsNullOrWhiteSpace(input)) return false;
        var trimmed = input.Trim().ToLowerInvariant();
        if (trimmed.Length > MaxLength || !Shape().IsMatch(trimmed)) return false;
        email = trimmed;
        return true;
    }

    /// <summary>For logs and UI: an****@example.com.</summary>
    public static string Mask(string email)
    {
        var at = email.IndexOf('@');
        if (at <= 0) return "****";
        var visible = Math.Min(2, at);
        return email[..visible] + new string('*', Math.Max(4, at - visible)) + email[at..];
    }
}
