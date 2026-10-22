using System.Net;
using System.Net.Http.Json;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

/// <summary>A family member's own (optional) mobile number, verified with a code before registering.</summary>
[Collection(ApiCollection.Name)]
public sealed class MemberMobileTests(PvsApiFactory factory)
{
    private const string Send = "/api/v1/members/mobile-verifications";
    private const string Verify = "/api/v1/members/mobile-verifications/verify";

    [Fact]
    public async Task VerifiedNumber_IsSavedWithTheMember()
    {
        var client = await factory.CreateSignedInClientAsync();
        var childMobile = PvsApiFactory.NewMobileNumber();

        var challenge = await SendCodeAsync(client, childMobile);
        var verified = await client.PostAsJsonAsync(Verify, new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode });
        Assert.Equal(HttpStatusCode.OK, verified.StatusCode);

        var request = RegistrationRequests.Student("Kavya Mobile");
        request["mobileNumber"] = childMobile;
        request["mobileVerificationId"] = challenge.ChallengeId;
        var id = await PvsApiFactory.RegisterMemberAsync(client, request);

        var profile = (await client.GetFromJsonAsync<Envelope<MemberProfileDto>>($"/api/v1/members/{id}"))!.Data!;
        Assert.Equal("+91" + childMobile, profile.MobileNumber);
    }

    [Fact]
    public async Task NumberIsOptional()
    {
        var client = await factory.CreateSignedInClientAsync();
        var id = await PvsApiFactory.RegisterMemberAsync(client, RegistrationRequests.Student("No Mobile"));
        var profile = (await client.GetFromJsonAsync<Envelope<MemberProfileDto>>($"/api/v1/members/{id}"))!.Data!;
        Assert.Null(profile.MobileNumber);
    }

    [Fact]
    public async Task UnverifiedOrMismatchedNumber_IsRejected()
    {
        var client = await factory.CreateSignedInClientAsync();
        var childMobile = PvsApiFactory.NewMobileNumber();

        // Not verified at all.
        var request = RegistrationRequests.Student("Unverified");
        request["mobileNumber"] = childMobile;
        Assert.Equal("mobileNumber", await RegisterErrorFieldAsync(client, request));

        // Code sent but never entered.
        var challenge = await SendCodeAsync(client, childMobile);
        request["mobileVerificationId"] = challenge.ChallengeId;
        Assert.Equal("mobileNumber", await RegisterErrorFieldAsync(client, request));

        // Verified, but for a different number than the one submitted.
        (await client.PostAsJsonAsync(Verify, new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode })).EnsureSuccessStatusCode();
        request["mobileNumber"] = PvsApiFactory.NewMobileNumber();
        Assert.Equal("mobileNumber", await RegisterErrorFieldAsync(client, request));
    }

    [Fact]
    public async Task VerificationFromAnotherAccount_DoesNotCount()
    {
        var parent = await factory.CreateSignedInClientAsync();
        var stranger = await factory.CreateSignedInClientAsync();
        var childMobile = PvsApiFactory.NewMobileNumber();

        var challenge = await SendCodeAsync(stranger, childMobile);
        // Only the account that asked for the code can check it...
        var foreignVerify = await parent.PostAsJsonAsync(Verify, new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode });
        Assert.Equal(HttpStatusCode.BadRequest, foreignVerify.StatusCode);

        // ...or use it to register.
        (await stranger.PostAsJsonAsync(Verify, new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode })).EnsureSuccessStatusCode();
        var request = RegistrationRequests.Student("Borrowed Proof");
        request["mobileNumber"] = childMobile;
        request["mobileVerificationId"] = challenge.ChallengeId;
        Assert.Equal("mobileNumber", await RegisterErrorFieldAsync(parent, request));
    }

    [Fact]
    public async Task MemberNumberCode_CannotBeUsedToSignIn()
    {
        var client = await factory.CreateSignedInClientAsync();
        var challenge = await SendCodeAsync(client, PvsApiFactory.NewMobileNumber());

        var signIn = await factory.CreateClient().PostAsJsonAsync("/api/v1/auth/verification-codes/verify",
            new { challengeId = challenge.ChallengeId, code = challenge.DevelopmentCode });
        Assert.Equal(HttpStatusCode.BadRequest, signIn.StatusCode);
    }

    [Fact]
    public async Task AccountsOwnNumber_NeedsNoCode()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var client = await factory.CreateSignedInClientAsync(mobile);
        var request = RegistrationRequests.Student("Same Number");
        request["mobileNumber"] = mobile;

        var id = await PvsApiFactory.RegisterMemberAsync(client, request);
        var profile = (await client.GetFromJsonAsync<Envelope<MemberProfileDto>>($"/api/v1/members/{id}"))!.Data!;
        Assert.Equal("+91" + mobile, profile.MobileNumber);
    }

    [Fact]
    public async Task SendingRequiresSignIn()
    {
        var response = await factory.CreateClient().PostAsJsonAsync(Send, new { mobileNumber = PvsApiFactory.NewMobileNumber() });
        Assert.Equal(HttpStatusCode.Unauthorized, response.StatusCode);
    }

    private static async Task<ChallengeData> SendCodeAsync(HttpClient client, string mobile)
    {
        var response = await client.PostAsJsonAsync(Send, new { mobileNumber = mobile });
        Assert.True(response.IsSuccessStatusCode, await response.Content.ReadAsStringAsync());
        return (await response.Content.ReadFromJsonAsync<Envelope<ChallengeData>>())!.Data!;
    }

    private static async Task<string?> RegisterErrorFieldAsync(HttpClient client, object request)
    {
        var response = await client.PostAsJsonAsync("/api/v1/members", request);
        Assert.Equal(HttpStatusCode.BadRequest, response.StatusCode);
        var body = await response.Content.ReadFromJsonAsync<Envelope<object>>();
        return body!.Errors.Select(e => e.Field).FirstOrDefault();
    }
}
