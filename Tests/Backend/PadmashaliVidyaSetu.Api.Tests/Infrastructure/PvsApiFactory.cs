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
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Services.Notifications;
using PadmashaliVidyaSetu.Api.Services.Locations;
using PadmashaliVidyaSetu.Api.Services.Verification;

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
            ["PhoneVerification:InternationalSender"] = "Development",
            ["PhoneVerification:TestLogin:MobileNumber"] = TestLoginMobile,
            ["PhoneVerification:TestLogin:Code"] = TestLoginCode,
            ["PhoneVerification:ExposeCodeInResponse"] = "true",
            ["PhoneVerification:ResendCooldownSeconds"] = "30",
            ["RateLimiting:VerificationPermitLimit"] = "10000",
            ["RateLimiting:AuthPermitLimit"] = "10000",
            ["RateLimiting:LookupPermitLimit"] = "10000",
            ["RateLimiting:EnquiryPermitLimit"] = "10000",
            ["RateLimiting:GlobalPermitLimit"] = "100000",
            ["Serilog:MinimumLevel:Default"] = "Warning",
            ["Firebase:AllUsersTopic"] = "all-test",
        }));

        builder.ConfigureServices(services =>
        {
            services.RemoveAll<IPinCodeProvider>();
            services.AddSingleton<IPinCodeProvider, FakePinCodeProvider>();
            // Never call Firebase from tests: record what would have been sent.
            services.RemoveAll<IPushSender>();
            services.AddSingleton<IPushSender>(PushSender);
            // Record every phone code (SMS / WhatsApp) instead of using the Development sender.
            services.RemoveAll<IVerificationCodeSender>();
            services.AddSingleton<IVerificationCodeSender>(CodeSender);
            // Record email verification codes instead of using SMTP.
            services.RemoveAll<IVerificationEmailSender>();
            services.AddSingleton<IVerificationEmailSender>(EmailSender);
            // Record website enquiry emails instead of using SMTP.
            services.RemoveAll<PadmashaliVidyaSetu.Api.Services.Website.IEnquiryMailer>();
            services.AddSingleton<PadmashaliVidyaSetu.Api.Services.Website.IEnquiryMailer>(EnquiryMailer);
        });
    }

    public FakePushSender PushSender { get; } = new();
    public FakeEmailSender EmailSender { get; } = new();
    public RecordingCodeSender CodeSender { get; } = new();
    public RecordingEnquiryMailer EnquiryMailer { get; } = new();

    /// <summary>The store-review test login used by the tests (national digits) and its fixed code.</summary>
    public const string TestLoginMobile = "9000012345";
    public const string TestLoginCode = "9876";

    /// <summary>A unique UAE mobile number in E.164 (a number outside India: code on WhatsApp).</summary>
    public static string NewUaeMobileNumber() => "+97150" + Random.Shared.Next(1_000_000, 9_999_999);

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

    /// <summary>A client signed in as an administrator (ADMIN or SUPER_ADMIN). Returns the mobile number too.</summary>
    public async Task<(HttpClient Client, string Mobile)> CreateAdminClientAsync(string roleCode = "ADMIN")
    {
        var mobile = NewMobileNumber();
        var client = CreateClient();
        var tokens = await SignInAsync(client, mobile);
        await WithDbAsync(async db =>
        {
            var accountId = await db.Accounts.Where(a => a.MobileNumber == "+91" + mobile).Select(a => a.AccountId).SingleAsync();
            var roleId = await db.Roles.Where(r => r.Code == roleCode).Select(r => r.Id).SingleAsync();
            db.AccountRoles.Add(new AccountRole { AccountId = accountId, RoleId = roleId, CreatedDate = DateTime.UtcNow });
            return await db.SaveChangesAsync();
        });

        // Roles are read when tokens are issued: refresh to get them into the access token.
        var refreshed = await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.RefreshToken });
        refreshed.EnsureSuccessStatusCode();
        var access = (await refreshed.Content.ReadFromJsonAsync<Envelope<TestTokens>>())!.Data!.AccessToken;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", access);
        return (client, mobile);
    }

    public Task<(HttpClient Client, string Mobile)> CreateSuperAdminAsync() => CreateAdminClientAsync("SUPER_ADMIN");

    /// <summary>Registers a member with the given request body and returns the Registration ID.</summary>
    public static async Task<string> RegisterMemberAsync(HttpClient client, object request)
    {
        var response = await client.PostAsJsonAsync("/api/v1/members", request);
        if (!response.IsSuccessStatusCode) throw new InvalidOperationException(await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<Envelope<PadmashaliVidyaSetu.Api.DTOs.RegistrationResultDto>>())!.Data!.RegistrationId;
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
public sealed record EmailChallengeData(Guid ChallengeId, string MaskedEmail, int CodeLength, string? DevelopmentCode);
public sealed record TestTokens(string AccessToken, string RefreshToken, bool IsNewAccount, int RegisteredMemberCount);

/// <summary>Records website enquiry emails instead of sending them.</summary>
public sealed class RecordingEnquiryMailer : PadmashaliVidyaSetu.Api.Services.Website.IEnquiryMailer
{
    public System.Collections.Concurrent.ConcurrentQueue<MimeKit.MimeMessage> Sent { get; } = new();

    public Task SendAsync(MimeKit.MimeMessage message, CancellationToken ct)
    {
        // The service disposes its message: keep a copy.
        using var buffer = new MemoryStream();
        message.WriteTo(buffer);
        buffer.Position = 0;
        Sent.Enqueue(MimeKit.MimeMessage.Load(buffer));
        return Task.CompletedTask;
    }
}

/// <summary>Records phone verification codes (SMS / WhatsApp) instead of sending them.</summary>
public sealed class RecordingCodeSender : IVerificationCodeSender
{
    public System.Collections.Concurrent.ConcurrentQueue<(string Mobile, string Code)> Sent { get; } = new();

    public Task SendAsync(string mobileNumberE164, string code, CancellationToken cancellationToken)
    {
        Sent.Enqueue((mobileNumberE164, code));
        return Task.CompletedTask;
    }
}

/// <summary>Records verification emails instead of sending them; <see cref="Fail"/> makes the next sends fail.</summary>
public sealed class FakeEmailSender : IVerificationEmailSender
{
    public System.Collections.Concurrent.ConcurrentQueue<(string Email, string Code)> Sent { get; } = new();
    public bool Fail { get; set; }

    public Task SendAsync(string email, string code, CancellationToken cancellationToken)
    {
        if (Fail) throw new PadmashaliVidyaSetu.Api.Common.ServiceUnavailableException("email down");
        Sent.Enqueue((email, code));
        return Task.CompletedTask;
    }
}

/// <summary>Records push notifications instead of sending them to Firebase.</summary>
public sealed class FakePushSender : IPushSender
{
    public sealed record SentPush(string Topic, string Title, string Body);

    public System.Collections.Concurrent.ConcurrentQueue<SentPush> Sent { get; } = new();
    public bool IsConfigured => true;

    public Task<string> SendToTopicAsync(string topic, string title, string body, CancellationToken ct)
    {
        Sent.Enqueue(new SentPush(topic, title, body));
        return Task.FromResult("projects/test/messages/" + Sent.Count);
    }
}

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
