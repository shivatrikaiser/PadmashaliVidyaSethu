using System.Net.Http.Headers;
using System.Net.Http.Json;
using System.Security.Cryptography;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Mvc.Testing;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.DependencyInjection.Extensions;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.Services.Locations;

namespace PadmashaliVidyaSetu.Api.Tests.Infrastructure;

/// <summary>
/// Hosts the real API in-process against a throw-away LocalDB database (migrated + seeded on startup, dropped on
/// dispose). The only substitute is the PIN-code provider, so tests do not depend on the internet.
/// </summary>
public sealed class PvsApiFactory : WebApplicationFactory<Program>, IAsyncLifetime
{
    private readonly string _databaseName = $"PadmashaliVidyaSetu_Tests_{Guid.NewGuid():N}";

    public string ConnectionString =>
        $"Server=(localdb)\\MSSQLLocalDB;Database={_databaseName};Trusted_Connection=True;TrustServerCertificate=True";

    protected override void ConfigureWebHost(IWebHostBuilder builder)
    {
        builder.UseEnvironment("Development");
        builder.ConfigureAppConfiguration((_, config) => config.AddInMemoryCollection(new Dictionary<string, string?>
        {
            ["ConnectionStrings:DefaultConnection"] = ConnectionString,
            ["Database:ApplyMigrationsOnStartup"] = "true",
            ["Jwt:SigningKey"] = Convert.ToBase64String(RandomNumberGenerator.GetBytes(48)),
            ["PhoneVerification:CodeHashingKey"] = Convert.ToBase64String(RandomNumberGenerator.GetBytes(48)),
            ["PhoneVerification:Sender"] = "Development",
            ["PhoneVerification:ExposeCodeInResponse"] = "true",
            ["PhoneVerification:ResendCooldownSeconds"] = "30",
            ["RateLimiting:VerificationPermitLimit"] = "10000",
            ["RateLimiting:AuthPermitLimit"] = "10000",
            ["RateLimiting:LookupPermitLimit"] = "10000",
            ["RateLimiting:GlobalPermitLimit"] = "100000",
            ["Serilog:MinimumLevel:Default"] = "Warning",
        }));

        builder.ConfigureServices(services =>
        {
            services.RemoveAll<IPinCodeProvider>();
            services.AddSingleton<IPinCodeProvider, FakePinCodeProvider>();
        });
    }

    public Task InitializeAsync() => Task.CompletedTask;

    async Task IAsyncLifetime.DisposeAsync()
    {
        await using (var scope = Services.CreateAsyncScope())
        {
            await scope.ServiceProvider.GetRequiredService<AppDbContext>().Database.EnsureDeletedAsync();
        }
        await base.DisposeAsync();
    }

    public async Task<T> WithDbAsync<T>(Func<AppDbContext, Task<T>> action)
    {
        await using var scope = Services.CreateAsyncScope();
        return await action(scope.ServiceProvider.GetRequiredService<AppDbContext>());
    }

    public Task<int> BackdateChallengesAsync(string mobile, TimeSpan by) => WithDbAsync(db =>
        db.PhoneVerificationChallenges
            .Where(c => c.MobileNumber == "+91" + mobile)
            .ExecuteUpdateAsync(s => s.SetProperty(c => c.CreatedDate, DateTime.UtcNow - by)));

    /// <summary>Unique, valid Indian mobile number per call so tests never share rate-limit state.</summary>
    public static string NewMobileNumber() => "9" + RandomNumberGenerator.GetInt32(100_000_000, 999_999_999);

    /// <summary>Runs the phone verification flow and returns a client authorised as that account.</summary>
    public async Task<HttpClient> CreateSignedInClientAsync(string? mobile = null)
    {
        var client = CreateClient();
        var tokens = await SignInAsync(client, mobile ?? NewMobileNumber());
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        return client;
    }

    public static async Task<TestTokens> SignInAsync(HttpClient client, string mobile)
    {
        var issued = await client.PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });
        issued.EnsureSuccessStatusCode();
        var challenge = (await issued.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;

        var verified = await client.PostAsJsonAsync("/api/v1/auth/verification-codes/verify",
            new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode });
        verified.EnsureSuccessStatusCode();
        return (await verified.Content.ReadFromJsonAsync<Envelope<TestTokens>>())!.Data!;
    }
}

[CollectionDefinition(Name)]
public sealed class ApiCollection : ICollectionFixture<PvsApiFactory>
{
    public const string Name = "api";
}

public sealed record Envelope<T>(bool Success, string Message, T? Data, List<ErrorItem> Errors);
public sealed record ErrorItem(string? Field, string Message);
public sealed record ChallengeData(Guid ChallengeId, string MaskedMobileNumber, int CodeLength, string? DevelopmentCode);
public sealed record TestTokens(string AccessToken, string RefreshToken, bool IsNewAccount, int RegisteredMemberCount);

/// <summary>Deterministic PIN data mirroring the shape of India Post responses.</summary>
public sealed class FakePinCodeProvider : IPinCodeProvider
{
    public const string PutturPin = "574201";
    public const string ShimogaPin = "577201";
    public const string UnknownPin = "999999";
    public const string UnavailablePin = "111111";

    public Task<IReadOnlyList<PostalLocality>> LookupAsync(string pinCode, CancellationToken ct) => pinCode switch
    {
        PutturPin => Task.FromResult<IReadOnlyList<PostalLocality>>(
        [
            new("Bolwar", "Dakshina Kannada", "Puttur", "Karnataka", "India"),
            new("Puttur(D.K.)", "Dakshina Kannada", "Puttur", "Karnataka", "India"),
        ]),
        ShimogaPin => Task.FromResult<IReadOnlyList<PostalLocality>>(
        [
            new("Shimoga", "Shimoga", "Shimoga", "Karnataka", "India"),
        ]),
        UnavailablePin => throw new PinCodeProviderUnavailableException("simulated outage"),
        _ => Task.FromResult<IReadOnlyList<PostalLocality>>([]),
    };
}
