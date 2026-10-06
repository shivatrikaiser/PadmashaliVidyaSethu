using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.JsonWebTokens;
using Microsoft.IdentityModel.Tokens;
using PadmashaliVidyaSetu.Api.Configuration;

namespace PadmashaliVidyaSetu.Api.Authentication;

public sealed record IssuedAccessToken(string Token, DateTime ExpiresAt);
public sealed record IssuedRefreshToken(string Token, string TokenHash, DateTime ExpiresAt);

public interface ITokenService
{
    IssuedAccessToken CreateAccessToken(int accountId, IEnumerable<string> roleCodes);
    IssuedRefreshToken CreateRefreshToken();
    string HashRefreshToken(string token);
}

public sealed class TokenService(IOptions<JwtOptions> options, SecurityKeys keys, TimeProvider clock) : ITokenService
{
    private readonly JwtOptions _options = options.Value;

    public IssuedAccessToken CreateAccessToken(int accountId, IEnumerable<string> roleCodes)
    {
        var now = clock.GetUtcNow().UtcDateTime;
        var expires = now.AddMinutes(_options.AccessTokenMinutes);

        // Deliberately minimal: no name, mobile number or other personal data inside the token.
        var claims = new List<Claim>
        {
            new(JwtRegisteredClaimNames.Sub, accountId.ToString()),
            new(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString("N")),
        };
        claims.AddRange(roleCodes.Select(r => new Claim(PvsClaimTypes.Role, r)));

        var descriptor = new SecurityTokenDescriptor
        {
            Issuer = _options.Issuer,
            Audience = _options.Audience,
            Subject = new ClaimsIdentity(claims),
            NotBefore = now,
            IssuedAt = now,
            Expires = expires,
            SigningCredentials = new SigningCredentials(keys.JwtSigningKey, SecurityAlgorithms.HmacSha256),
        };

        return new IssuedAccessToken(new JsonWebTokenHandler().CreateToken(descriptor), expires);
    }

    public IssuedRefreshToken CreateRefreshToken()
    {
        var token = Base64UrlEncoder.Encode(RandomNumberGenerator.GetBytes(48));
        return new IssuedRefreshToken(token, HashRefreshToken(token),
            clock.GetUtcNow().UtcDateTime.AddDays(_options.RefreshTokenDays));
    }

    public string HashRefreshToken(string token) =>
        Convert.ToHexString(SHA256.HashData(Encoding.UTF8.GetBytes(token)));
}

public static class PvsClaimTypes
{
    public const string Role = "role";
    public const string Subject = JwtRegisteredClaimNames.Sub;
}
