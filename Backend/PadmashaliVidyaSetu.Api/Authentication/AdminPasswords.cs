using Microsoft.AspNetCore.Identity;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Entities.Accounts;

namespace PadmashaliVidyaSetu.Api.Authentication;

/// <summary>
/// Admin portal passwords: hashing (ASP.NET Core Identity's PBKDF2 format, salted, versioned) and the rules for a
/// password a Super Admin sets. There is no self-service change or reset: a Super Admin sets a new one.
/// </summary>
public sealed class AdminPasswords
{
    public const int MinLength = 8;
    public const int MaxLength = 128;
    public const int MaxFailedAttempts = 5;
    public static readonly TimeSpan Lockout = TimeSpan.FromMinutes(15);

    private readonly PasswordHasher<Account> _hasher = new();

    /// <summary>A real hash checked when the account does not exist, so the response time does not reveal it.</summary>
    private readonly string _dummyHash;

    public AdminPasswords() => _dummyHash = _hasher.HashPassword(null!, Guid.NewGuid().ToString());

    public string Hash(string password) => _hasher.HashPassword(null!, password);

    /// <summary>Checks <paramref name="password"/>; <paramref name="hash"/> null still costs the same time and fails.</summary>
    public bool Verify(string? hash, string password) =>
        _hasher.VerifyHashedPassword(null!, hash ?? _dummyHash, password) != PasswordVerificationResult.Failed
        && hash is not null;

    /// <summary>Throws a field error ("password") when the password does not meet the rules.</summary>
    public static void Validate(string? password)
    {
        if (string.IsNullOrWhiteSpace(password) || password.Length < MinLength)
            throw new RequestValidationException("password", $"Use at least {MinLength} characters.");
        if (password.Length > MaxLength)
            throw new RequestValidationException("password", $"Use at most {MaxLength} characters.");
        if (password != password.Trim())
            throw new RequestValidationException("password", "The password cannot start or end with a space.");
    }
}
