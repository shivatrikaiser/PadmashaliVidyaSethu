using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Logging;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface IAdminUserService
{
    Task<IReadOnlyList<AdminUserDto>> GetAdminsAsync(CancellationToken ct);
    Task<AdminUserDto> GrantAsync(GrantRoleRequest request, CancellationToken ct);
    Task RevokeAsync(int accountId, string roleCode, CancellationToken ct);
    Task<AdminUserDto> SetPasswordAsync(int accountId, string? password, CancellationToken ct);
}

/// <summary>
/// Who may use the admin portal. Roles are put into the access token at sign-in / refresh, so a granted role applies
/// at the person's next sign-in; a revoked role also signs them out everywhere (refresh tokens revoked).
/// </summary>
public sealed class AdminUserService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IAuditLogger audit,
    AdminPasswords passwords,
    TimeProvider clock) : IAdminUserService
{
    private static readonly string[] AdminRoles = [RoleCodes.Admin, RoleCodes.SuperAdmin];

    public async Task<IReadOnlyList<AdminUserDto>> GetAdminsAsync(CancellationToken ct)
    {
        var rows = await db.Accounts.AsNoTracking()
            .Where(a => a.AccountRoles.Any(r => AdminRoles.Contains(r.Role.Code)))
            .Select(a => new
            {
                a.AccountId, a.MobileNumber, a.LastLoginDate, HasPassword = a.PasswordHash != null, a.PasswordSetDate,
                Roles = a.AccountRoles.Select(r => r.Role.Code).ToList(),
            })
            .ToListAsync(ct);

        return rows
            .Select(a => new AdminUserDto(a.AccountId, a.MobileNumber, a.Roles.Where(AdminRoles.Contains).Order().ToList(),
                a.LastLoginDate, a.HasPassword, a.PasswordSetDate))
            .OrderBy(a => a.MobileNumber)
            .ToList();
    }

    public async Task<AdminUserDto> GrantAsync(GrantRoleRequest request, CancellationToken ct)
    {
        if (!MobileNumber.TryNormalize(request.MobileNumber, out var mobile))
            throw Invalid("mobileNumber", "Enter a valid 10-digit Indian mobile number.");
        var roleCode = request.RoleCode.Tidy().ToUpperInvariant();
        if (!AdminRoles.Contains(roleCode)) throw Invalid("roleCode", "Choose ADMIN or SUPER_ADMIN.");
        var password = string.IsNullOrEmpty(request.Password) ? null : request.Password;
        if (password is not null) AdminPasswords.Validate(password);

        var now = clock.GetUtcNow().UtcDateTime;
        var roles = await db.Roles.Where(r => r.Code == roleCode || r.Code == RoleCodes.Member).ToListAsync(ct);
        var account = await db.Accounts.Include(a => a.AccountRoles).SingleOrDefaultAsync(a => a.MobileNumber == mobile, ct);
        if (account is null)
        {
            // The person has not signed in yet: create the account so the role is ready at their first sign-in.
            account = new Account { MobileNumber = mobile };
            account.AccountRoles.Add(new AccountRole { RoleId = roles.Single(r => r.Code == RoleCodes.Member).Id, CreatedDate = now, CreatedBy = currentUser.AuditName });
            db.Accounts.Add(account);
        }

        var role = roles.Single(r => r.Code == roleCode);
        if (account.AccountRoles.All(r => r.RoleId != role.Id))
        {
            account.AccountRoles.Add(new AccountRole { RoleId = role.Id, CreatedDate = now, CreatedBy = currentUser.AuditName });
            audit.Add(AuditActions.RoleGranted, "Account", MobileNumber.Mask(mobile), roleCode);
        }
        if (password is not null) ApplyPassword(account, password, now);
        await db.SaveChangesAsync(ct);

        return (await GetAdminsAsync(ct)).Single(a => a.MobileNumber == mobile);
    }

    public async Task RevokeAsync(int accountId, string roleCode, CancellationToken ct)
    {
        roleCode = roleCode.ToUpperInvariant();
        if (!AdminRoles.Contains(roleCode)) throw new NotFoundException("Role not found.");
        if (roleCode == RoleCodes.SuperAdmin && accountId == currentUser.AccountId)
            throw new BusinessRuleException("You cannot remove your own Super Admin role. Ask another Super Admin.");

        var link = await db.AccountRoles.Include(r => r.Account)
                       .SingleOrDefaultAsync(r => r.AccountId == accountId && r.Role.Code == roleCode, ct)
                   ?? throw new NotFoundException("This account does not have that role.");

        if (roleCode == RoleCodes.SuperAdmin &&
            await db.AccountRoles.CountAsync(r => r.Role.Code == RoleCodes.SuperAdmin, ct) <= 1)
            throw new BusinessRuleException("At least one Super Admin must remain.");

        db.AccountRoles.Remove(link);
        // Sign them out everywhere so the removed role is not kept in a refreshed token.
        var now = clock.GetUtcNow().UtcDateTime;
        await db.RefreshTokens.Where(t => t.AccountId == accountId && t.RevokedDate == null)
            .ExecuteUpdateAsync(t => t.SetProperty(x => x.RevokedDate, now), ct);
        audit.Add(AuditActions.RoleRevoked, "Account", MobileNumber.Mask(link.Account.MobileNumber), roleCode);
        await db.SaveChangesAsync(ct);
    }

    public async Task<AdminUserDto> SetPasswordAsync(int accountId, string? password, CancellationToken ct)
    {
        AdminPasswords.Validate(password);
        var account = await db.Accounts
                          .Where(a => a.AccountId == accountId && a.AccountRoles.Any(r => AdminRoles.Contains(r.Role.Code)))
                          .SingleOrDefaultAsync(ct)
                      ?? throw new NotFoundException("Admin user not found.");

        var now = clock.GetUtcNow().UtcDateTime;
        ApplyPassword(account, password!, now);
        if (accountId != currentUser.AccountId)
        {
            // Sessions opened with the old password end; your own stays signed in.
            await db.RefreshTokens.Where(t => t.AccountId == accountId && t.RevokedDate == null)
                .ExecuteUpdateAsync(t => t.SetProperty(x => x.RevokedDate, now), ct);
        }
        await db.SaveChangesAsync(ct);
        return (await GetAdminsAsync(ct)).Single(a => a.AccountId == accountId);
    }

    private void ApplyPassword(Account account, string password, DateTime now)
    {
        account.PasswordHash = passwords.Hash(password);
        account.PasswordSetDate = now;
        account.FailedPasswordAttempts = 0;
        account.PasswordLockedUntil = null;
        // Never the password or its hash in the audit log.
        audit.Add(AuditActions.PasswordSet, "Account", MobileNumber.Mask(account.MobileNumber));
    }

    private static RequestValidationException Invalid(string field, string message) => new([new ApiError(field, message)]);
}
