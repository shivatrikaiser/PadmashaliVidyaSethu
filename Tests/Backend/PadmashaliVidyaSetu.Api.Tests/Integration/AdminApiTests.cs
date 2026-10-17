using System.Net;
using System.Net.Http.Headers;
using System.Net.Http.Json;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class AdminApiTests(PvsApiFactory factory)
{
    [Fact]
    public async Task AdminMe_ForMember_Returns403()
    {
        var client = await factory.CreateSignedInClientAsync();
        var response = await client.GetAsync("/api/v1/admin/me");
        Assert.Equal(HttpStatusCode.Forbidden, response.StatusCode);
    }

    [Fact]
    public async Task AdminMe_ForAdmin_ReturnsRoles()
    {
        var mobile = PvsApiFactory.NewMobileNumber();
        var client = factory.CreateClient();
        var tokens = await PvsApiFactory.SignInAsync(client, mobile);
        await factory.WithDbAsync(async db =>
        {
            var accountId = await db.Accounts.Where(a => a.MobileNumber == "+91" + mobile).Select(a => a.AccountId).SingleAsync();
            var adminRoleId = await db.Roles.Where(r => r.Code == RoleCodes.Admin).Select(r => r.Id).SingleAsync();
            db.AccountRoles.Add(new AccountRole { AccountId = accountId, RoleId = adminRoleId, CreatedDate = DateTime.UtcNow });
            return await db.SaveChangesAsync();
        });

        // Roles are read when tokens are issued, so the new role applies from the next refresh.
        var refreshed = await client.PostAsJsonAsync("/api/v1/auth/token/refresh", new { refreshToken = tokens.RefreshToken });
        var access = (await refreshed.Content.ReadFromJsonAsync<Envelope<TestTokens>>())!.Data!.AccessToken;
        client.DefaultRequestHeaders.Authorization = new AuthenticationHeaderValue("Bearer", access);
        var me = await client.GetFromJsonAsync<Envelope<AdminMeDto>>("/api/v1/admin/me");

        Assert.Equal([RoleCodes.Admin, RoleCodes.Member], me!.Data!.Roles);
        Assert.EndsWith(mobile[^4..], me.Data.MaskedMobileNumber);
    }
}
