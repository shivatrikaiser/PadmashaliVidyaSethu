using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

/// <summary>Store-review test login (PhoneVerification:TestLogin): a fixed code and nothing is ever sent.</summary>
[Collection(ApiCollection.Name)]
public sealed class TestLoginTests(PvsApiFactory factory)
{
    private const string E164 = "+91" + PvsApiFactory.TestLoginMobile;

    private async Task<ChallengeData> RequestCodeAsync(HttpClient client, string mobile = PvsApiFactory.TestLoginMobile)
    {
        var response = await client.PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });
        Assert.True(response.IsSuccessStatusCode, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;
    }

    private static Task<HttpResponseMessage> VerifyAsync(HttpClient client, Guid challengeId, string code) =>
        client.PostAsJsonAsync("/api/v1/auth/verification-codes/verify", new { challengeId, code });

    [Fact]
    public async Task TestNumber_SignsInWithTheFixedCode_AndNothingIsSent()
    {
        var client = factory.CreateClient();

        var challenge = await RequestCodeAsync(client, "+91 " + PvsApiFactory.TestLoginMobile);

        Assert.DoesNotContain(factory.CodeSender.Sent, s => s.Mobile == E164);
        var verified = await VerifyAsync(client, challenge.ChallengeId, PvsApiFactory.TestLoginCode);
        Assert.Equal(HttpStatusCode.OK, verified.StatusCode);
        Assert.False(string.IsNullOrEmpty((await verified.Content.ReadFromJsonAsync<Envelope<TestTokens>>())!.Data!.AccessToken));
    }

    [Fact]
    public async Task TestNumber_WrongCodeIsRejected()
    {
        var client = factory.CreateClient();
        var challenge = await RequestCodeAsync(client);

        var wrong = await VerifyAsync(client, challenge.ChallengeId, "1111");

        Assert.Equal(HttpStatusCode.BadRequest, wrong.StatusCode);
    }

    [Fact]
    public async Task TestNumber_IsNotHeldBackBySendLimits()
    {
        var client = factory.CreateClient();
        // More requests, back to back, than the cooldown and hourly limit allow for a normal number.
        for (var i = 0; i < 7; i++) await RequestCodeAsync(client);
    }

    [Fact]
    public async Task OtherNumbers_StillGetARandomCodeSent()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var challenge = await RequestCodeAsync(factory.CreateClient(), mobile);

        Assert.Contains(factory.CodeSender.Sent, s => s.Mobile == "+91" + mobile && s.Code == challenge.DevelopmentCode);
    }

    [Fact]
    public async Task TestNumber_AsAMembersOwnNumber_IsVerifiedNormally()
    {
        var client = await factory.CreateSignedInClientAsync();
        // As a member's own number the normal send limits apply: clear the sign-in codes other tests requested.
        await factory.BackdateChallengesAsync(PvsApiFactory.TestLoginMobile, TimeSpan.FromHours(2));

        var response = await client.PostAsJsonAsync("/api/v1/members/mobile-verifications",
            new { mobileNumber = PvsApiFactory.TestLoginMobile });

        response.EnsureSuccessStatusCode();
        var challenge = (await response.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;
        Assert.Contains(factory.CodeSender.Sent, s => s.Mobile == E164 && s.Code == challenge.DevelopmentCode);
    }

    [Fact]
    public async Task TestNumber_DeleteAccount_ClosesMembersButTheNumberCanSignInAgain()
    {
        var client = factory.CreateClient();
        var challenge = await RequestCodeAsync(client);
        var tokens = (await (await VerifyAsync(client, challenge.ChallengeId, PvsApiFactory.TestLoginCode))
            .Content.ReadFromJsonAsync<Envelope<TestTokens>>())!.Data!;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        var registrationId = await PvsApiFactory.RegisterMemberAsync(client, RegistrationRequests.Student("Reviewer Child"));

        (await client.PostAsync("/api/v1/me/deletion", null)).EnsureSuccessStatusCode();

        Assert.False(await factory.WithDbAsync(db => db.Members.Where(m => m.RegistrationId == registrationId).Select(m => m.IsActive).SingleAsync()));
        var account = await factory.WithDbAsync(db => db.Accounts.AsNoTracking().SingleAsync(a => a.MobileNumber == E164));
        Assert.Null(account.DeletedDate);
        Assert.True(account.IsActive);

        var again = factory.CreateClient();
        var next = await RequestCodeAsync(again);
        Assert.Equal(HttpStatusCode.OK, (await VerifyAsync(again, next.ChallengeId, PvsApiFactory.TestLoginCode)).StatusCode);
    }

    [Theory]
    [InlineData(null, null, true)] // off
    [InlineData("917795276699", "9876", true)]
    [InlineData("917795276699", "987", false)]
    [InlineData("917795276699", "98a6", false)]
    [InlineData("12345", "9876", false)]
    public void Settings_AreCheckedAtStartup(string? mobile, string? code, bool valid) =>
        Assert.Equal(valid, new TestLoginOptions { MobileNumber = mobile, Code = code }.IsValid);
}
