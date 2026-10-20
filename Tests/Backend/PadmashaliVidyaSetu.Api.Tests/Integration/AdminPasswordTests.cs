using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class AdminPasswordTests(PvsApiFactory factory)
{
    private const string SignIn = "/api/v1/auth/admin/sign-in";

    [Fact]
    public async Task SuperAdmin_SetsPassword_AdminSignsInWithIt()
    {
        var (superAdmin, _) = await factory.CreateSuperAdminAsync();
        var mobile = PvsApiFactory.NewMobileNumber();
        var anonymous = factory.CreateClient();

        // Granted with a password straight away (the person never needs a verification code).
        var granted = await superAdmin.PostAsJsonAsync("/api/v1/admin/users", new { mobileNumber = mobile, roleCode = "ADMIN", password = "Udupi@2026" });
        Assert.Equal(HttpStatusCode.OK, granted.StatusCode);
        var admin = (await granted.Content.ReadFromJsonAsync<Envelope<AdminUserDto>>())!.Data!;
        Assert.True(admin.HasPassword);

        var signedIn = await anonymous.PostAsJsonAsync(SignIn, new { mobileNumber = mobile, password = "Udupi@2026" });
        Assert.Equal(HttpStatusCode.OK, signedIn.StatusCode);
        var tokens = (await signedIn.Content.ReadFromJsonAsync<Envelope<TestTokens>>())!.Data!;
        var adminClient = factory.CreateClient();
        adminClient.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", tokens.AccessToken);
        Assert.Equal(HttpStatusCode.OK, (await adminClient.GetAsync("/api/v1/admin/me")).StatusCode);

        // A new password replaces the old one and ends the admin's sessions.
        var reset = await superAdmin.PutAsJsonAsync($"/api/v1/admin/users/{admin.AccountId}/password", new { password = "NewPass#2027" });
        Assert.Equal(HttpStatusCode.OK, reset.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, (await anonymous.PostAsJsonAsync(SignIn, new { mobileNumber = mobile, password = "Udupi@2026" })).StatusCode);
        Assert.Equal(HttpStatusCode.OK, (await anonymous.PostAsJsonAsync(SignIn, new { mobileNumber = mobile, password = "NewPass#2027" })).StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized,
            (await anonymous.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.RefreshToken })).StatusCode);

        // The hash is stored, never the password.
        var stored = await factory.WithDbAsync(db => db.Accounts.Where(a => a.MobileNumber == "+91" + mobile).Select(a => a.PasswordHash).SingleAsync());
        Assert.DoesNotContain("NewPass", stored);
    }

    [Fact]
    public async Task PasswordSignIn_OnlyForAdmins_SameMessageForEveryFailure()
    {
        var anonymous = factory.CreateClient();
        var member = PvsApiFactory.NewMobileNumber();
        await PvsApiFactory.SignInAsync(anonymous, member);
        await factory.WithDbAsync(db => db.Accounts.Where(a => a.MobileNumber == "+91" + member)
            .ExecuteUpdateAsync(s => s.SetProperty(a => a.PasswordHash, "AQAAAAIAAYagAAAAEJunk")));

        var unknown = await anonymous.PostAsJsonAsync(SignIn, new { mobileNumber = PvsApiFactory.NewMobileNumber(), password = "Whatever123" });
        var notAdmin = await anonymous.PostAsJsonAsync(SignIn, new { mobileNumber = member, password = "Whatever123" });
        Assert.Equal(HttpStatusCode.Unauthorized, unknown.StatusCode);
        Assert.Equal(HttpStatusCode.Unauthorized, notAdmin.StatusCode);
        Assert.Equal((await unknown.Content.ReadFromJsonAsync<Envelope<object>>())!.Message,
            (await notAdmin.Content.ReadFromJsonAsync<Envelope<object>>())!.Message);
    }

    [Fact]
    public async Task PasswordSignIn_LocksAfterFiveWrongPasswords()
    {
        var (superAdmin, _) = await factory.CreateSuperAdminAsync();
        var mobile = PvsApiFactory.NewMobileNumber();
        (await superAdmin.PostAsJsonAsync("/api/v1/admin/users", new { mobileNumber = mobile, roleCode = "ADMIN", password = "Correct#123" })).EnsureSuccessStatusCode();
        var anonymous = factory.CreateClient();

        for (var i = 0; i < 5; i++)
            Assert.Equal(HttpStatusCode.Unauthorized, (await anonymous.PostAsJsonAsync(SignIn, new { mobileNumber = mobile, password = "wrong-pass" })).StatusCode);

        var locked = await anonymous.PostAsJsonAsync(SignIn, new { mobileNumber = mobile, password = "Correct#123" });
        Assert.Equal(HttpStatusCode.Unauthorized, locked.StatusCode);
        Assert.Contains("Too many incorrect attempts", (await locked.Content.ReadFromJsonAsync<Envelope<object>>())!.Message);
    }

    [Fact]
    public async Task SetPassword_SuperAdminOnly_Validated()
    {
        var (admin, adminMobile) = await factory.CreateAdminClientAsync();
        var (superAdmin, _) = await factory.CreateSuperAdminAsync();
        var adminId = await factory.WithDbAsync(db => db.Accounts.Where(a => a.MobileNumber == "+91" + adminMobile).Select(a => a.AccountId).SingleAsync());

        Assert.Equal(HttpStatusCode.Forbidden, (await admin.PutAsJsonAsync($"/api/v1/admin/users/{adminId}/password", new { password = "Long-enough-1" })).StatusCode);
        Assert.Equal(HttpStatusCode.BadRequest, (await superAdmin.PutAsJsonAsync($"/api/v1/admin/users/{adminId}/password", new { password = "short" })).StatusCode);
        Assert.Equal(HttpStatusCode.NotFound, (await superAdmin.PutAsJsonAsync("/api/v1/admin/users/999999/password", new { password = "Long-enough-1" })).StatusCode);
    }
}
