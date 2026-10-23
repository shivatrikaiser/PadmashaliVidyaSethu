using System.Net;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

/// <summary>"Delete my account": nothing is removed, the account is marked deleted and its number is refused.</summary>
[Collection(ApiCollection.Name)]
public sealed class AccountDeletionTests(PvsApiFactory factory)
{
    private const string DeletedMessage = "Your account is deleted. Hence can't re-register.";

    [Fact]
    public async Task DeletedAccount_IsKeptForTheRecords_AndCannotSignInOrRegisterAgain()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var client = factory.CreateClient();
        var tokens = await PvsApiFactory.SignInAsync(client, mobile);
        client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        var registrationId = await PvsApiFactory.RegisterMemberAsync(client, RegistrationRequests.Student("Deleted Member"));

        var deleted = await client.PostAsync("/api/v1/me/deletion", null);
        Assert.Equal(HttpStatusCode.OK, deleted.StatusCode);

        // Kept, marked deleted / inactive.
        var account = await factory.WithDbAsync(db => db.Accounts.AsNoTracking().SingleAsync(a => a.MobileNumber == "+91" + mobile));
        Assert.NotNull(account.DeletedDate);
        Assert.False(account.IsActive);
        var member = await factory.WithDbAsync(db => db.Members.AsNoTracking().SingleAsync(m => m.RegistrationId == registrationId));
        Assert.False(member.IsActive);
        Assert.Equal("Deleted Member", member.FullName);

        // Every session ended.
        var refresh = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.RefreshToken });
        Assert.Equal(HttpStatusCode.Unauthorized, refresh.StatusCode);

        // The number is refused before any code is sent.
        var again = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });
        Assert.Equal(HttpStatusCode.Forbidden, again.StatusCode);
        var body = await again.Content.ReadFromJsonAsync<Envelope<object>>();
        Assert.Equal(DeletedMessage, body!.Message);
        Assert.Equal(0, await factory.WithDbAsync(db => db.PhoneVerificationChallenges.CountAsync(c =>
            c.MobileNumber == "+91" + mobile && c.CreatedDate > account.DeletedDate)));
    }

    [Fact]
    public async Task CodeIssuedBeforeDeletion_CannotSignInAfterwards()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var client = factory.CreateClient();
        var tokens = await PvsApiFactory.SignInAsync(client, mobile);

        // A code requested before the deletion (past the resend cooldown of the sign-in code) ...
        await factory.BackdateChallengesAsync(mobile, TimeSpan.FromMinutes(1));
        var issued = await client.PostAsJsonAsync("/api/v1/auth/verification-codes", new { mobileNumber = mobile });
        var challenge = (await issued.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;

        client.DefaultRequestHeaders.Authorization = new System.Net.Http.Headers.AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        (await client.PostAsync("/api/v1/me/deletion", null)).EnsureSuccessStatusCode();

        // ... is refused when used afterwards.
        var verify = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/verification-codes/verify",
            new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode });
        Assert.Equal(HttpStatusCode.Forbidden, verify.StatusCode);
        Assert.Equal(DeletedMessage, (await verify.Content.ReadFromJsonAsync<Envelope<object>>())!.Message);
    }

    [Fact]
    public async Task Deletion_NeedsASignedInAccount()
    {
        var response = await factory.CreateClient().PostAsync("/api/v1/me/deletion", null);
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }
}
