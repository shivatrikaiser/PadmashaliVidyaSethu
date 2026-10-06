using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using PadmashaliVidyaSetu.Api.Configuration;

namespace PadmashaliVidyaSetu.Api.Authentication;

/// <summary>
/// Resolves the server secrets. Outside Development a missing or short secret stops the application from starting.
/// In Development a missing secret is replaced with a random per-process key (with a warning), so a fresh clone runs
/// without any secret being committed; tokens then stop working after a restart, which is acceptable locally.
/// </summary>
public sealed class SecurityKeys
{
    private const int MinimumKeyBytes = 32;

    public SecurityKeys(IOptions<JwtOptions> jwt, IOptions<PhoneVerificationOptions> verification,
        IHostEnvironment env, ILogger<SecurityKeys> logger)
    {
        JwtSigningKey = new SymmetricSecurityKey(Resolve(jwt.Value.SigningKey, "Jwt:SigningKey", env, logger));
        CodeHashingKey = Resolve(verification.Value.CodeHashingKey, "PhoneVerification:CodeHashingKey", env, logger);
    }

    public SymmetricSecurityKey JwtSigningKey { get; }
    public byte[] CodeHashingKey { get; }

    private static byte[] Resolve(string? configured, string name, IHostEnvironment env, ILogger logger)
    {
        if (!string.IsNullOrWhiteSpace(configured))
        {
            var bytes = Encoding.UTF8.GetBytes(configured);
            if (bytes.Length >= MinimumKeyBytes) return bytes;
            if (!env.IsDevelopment())
                throw new InvalidOperationException($"{name} must be at least {MinimumKeyBytes} bytes.");
        }
        else if (!env.IsDevelopment())
        {
            throw new InvalidOperationException(
                $"{name} is not configured. Supply it via environment variable or secret store.");
        }

        logger.LogWarning("{Setting} is not configured (or too short); using an ephemeral development key. " +
                          "Run 'dotnet user-secrets set \"{Setting}\" <value>' to keep sessions across restarts.", name, name);
        return RandomNumberGenerator.GetBytes(MinimumKeyBytes);
    }
}
