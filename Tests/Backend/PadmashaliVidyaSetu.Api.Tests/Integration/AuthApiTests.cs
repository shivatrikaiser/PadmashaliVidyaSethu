using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class AuthApiTests(PvsApiFactory factory)
{
    [Theory]
    [InlineData("")]
    [InlineData("12345")]
    [InlineData("5876543210")] // Indian mobiles start with 6-9
    [InlineData("98765432101")]
    public async Task RequestCode_InvalidMobile_Returns400WithFieldError(string mobile)
    {
        var response = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.False(body!.Success);
        Assert.Contains(body.Errors, e => e.Field == "mobileNumber");
    }

    [Fact]
    public async Task RequestCode_IssuesFourDigitCode_AndMasksNumber()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var response = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });

        response.EnsureSuccessStatusCode();
        var data = (await response.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;
        Assert.Equal(4, data.CodeLength);
        Assert.Matches(@"^\d{4}$", data.DevelopmentCode);
        Assert.DoesNotContain(mobile, data.MaskedMobileNumber);
        Assert.EndsWith(mobile[^4..], data.MaskedMobileNumber);
    }

    [Fact]
    public async Task StoredChallenge_NeverContainsPlainCode()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var response = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });
        var data = (await response.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;

        var stored = await factory.WithDbAsync(db => db.PhoneVerificationChallenges.SingleAsync(c => c.ChallengeId == data.ChallengeId));
        Assert.Equal(64, stored.CodeHash.Length);
        Assert.DoesNotContain(data.DevelopmentCode!, stored.CodeHash);
    }

    [Fact]
    public async Task RequestCode_TwiceWithinCooldown_Returns429()
    {
        var client = factory.CreateClient();
        var mobile = PvsApiFactory.NewMobileNumber();
        (await client.PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile })).EnsureSuccessStatusCode();

        var second = await client.PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });

        Assert.Equal(HttpStatusCode.TooManyRequests, second.StatusCode);
        Assert.True(second.Headers.Contains("Retry-After"));
    }

    [Theory]
    [InlineData("123")]
    [InlineData("12345")]
    [InlineData("12a4")]
    public async Task Verify_CodeNotExactlyFourDigits_Returns400(string code)
    {
        var response = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/verification-codes/verify",
            new { challengeId = Guid.NewGuid(), code });

        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Contains(body!.Errors, e => e.Field == "code" && e.Message.Contains("4 digits"));
    }

    [Fact]
    public async Task Verify_TooManyWrongAttempts_LocksChallengeEvenForCorrectCode()
    {
        var client = factory.CreateClient();
        var issued = await client.PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = PvsApiFactory.NewMobileNumber() });
        var challenge = (await issued.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;
        var wrong = challenge.DevelopmentCode == "0000" ? "1111" : "0000";

        for (var i = 0; i < 5; i++)
        {
            var attempt = await client.PostAsJsonAsync("/api/v1/auth/verification-codes/verify", new { challengeId = challenge.ChallengeId, code = wrong });
            Assert.Equal(HttpStatusCode.BadRequest, attempt.StatusCode);
        }

        var correct = await client.PostAsJsonAsync("/api/v1/auth/verification-codes/verify",
            new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode });
        Assert.Equal(HttpStatusCode.BadRequest, correct.StatusCode);
    }

    [Fact]
    public async Task Verify_CodeIsSingleUse()
    {
        var client = factory.CreateClient();
        var issued = await client.PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = PvsApiFactory.NewMobileNumber() });
        var challenge = (await issued.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;
        var payload = new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode };

        (await client.PostAsJsonAsync("/api/v1/auth/verification-codes/verify", payload)).EnsureSuccessStatusCode();
        var again = await client.PostAsJsonAsync("/api/v1/auth/verification-codes/verify", payload);

        Assert.Equal(HttpStatusCode.BadRequest, again.StatusCode);
    }

    [Fact]
    public async Task Verify_FirstTime_CreatesAccount_SecondTime_SignsInExistingAccount()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var first = await PvsApiFactory.SignInAsync(factory.CreateClient(), mobile);
        await factory.BackdateChallengesAsync(mobile, TimeSpan.FromMinutes(2)); // step past the resend cooldown
        var second = await PvsApiFactory.SignInAsync(factory.CreateClient(), mobile);

        Assert.True(first.IsNewAccount);
        Assert.False(second.IsNewAccount);
        var count = await factory.WithDbAsync(db => db.Accounts.CountAsync(a => a.MobileNumber == "+91" + mobile));
        Assert.Equal(1, count);
    }

    [Fact]
    public async Task ProtectedEndpoint_WithoutToken_Returns401Envelope()
    {
        var response = await factory.CreateClient().GetAsync("/api/v1/me");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.False(body!.Success);
    }

    [Fact]
    public async Task ProtectedEndpoint_WithTamperedToken_Returns401()
    {
        var client = factory.CreateClient();
        var tokens = await PvsApiFactory.SignInAsync(client, PvsApiFactory.NewMobileNumber());
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken[..^4] + "AAAA");

        var response = await client.GetAsync("/api/v1/me");

        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    [Fact]
    public async Task Refresh_RotatesToken_AndReuseRevokesAllSessions()
    {
        var client = factory.CreateClient();
        var tokens = await PvsApiFactory.SignInAsync(client, PvsApiFactory.NewMobileNumber());

        var rotated = await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.RefreshToken });
        rotated.EnsureSuccessStatusCode();
        var newTokens = (await rotated.Content.ReadFromJsonAsync<Envelope<TestTokens>>())!.Data!;
        Assert.NotEqual(tokens.RefreshToken, newTokens.RefreshToken);

        var reuse = await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.RefreshToken });
        Assert.Equal(HttpStatusCode.Unauthorized, reuse.StatusCode);

        var afterTheft = await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = newTokens.RefreshToken });
        Assert.Equal(HttpStatusCode.Unauthorized, afterTheft.StatusCode);
    }

    [Fact]
    public async Task Logout_RevokesRefreshToken()
    {
        var client = factory.CreateClient();
        var tokens = await PvsApiFactory.SignInAsync(client, PvsApiFactory.NewMobileNumber());
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);

        (await client.PostAsJsonAsync("/api/v1/auth/logout", new { refreshToken = tokens.RefreshToken })).EnsureSuccessStatusCode();
        var refresh = await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.RefreshToken });

        Assert.Equal(HttpStatusCode.Unauthorized, refresh.StatusCode);
    }

    [Fact]
    public async Task Responses_CarrySecurityHeaders()
    {
        var response = await factory.CreateClient().GetAsync("/health");

        Assert.Equal("nosniff", response.Headers.GetValues("X-Content-Type-Options").Single());
        Assert.Equal("DENY", response.Headers.GetValues("X-Frame-Options").Single());
    }
}
