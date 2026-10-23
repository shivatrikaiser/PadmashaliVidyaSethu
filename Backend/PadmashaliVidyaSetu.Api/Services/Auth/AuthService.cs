using System.Security.Cryptography;
using System.Text;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Logging;
using PadmashaliVidyaSetu.Api.Services.Verification;

namespace PadmashaliVidyaSetu.Api.Services.Auth;

public interface IAuthService
{
    Task<VerificationCodeIssuedResponse> RequestVerificationCodeAsync(string mobileNumber, CancellationToken ct);
    Task<AuthTokensResponse> VerifyCodeAsync(Guid challengeId, string code, CancellationToken ct);
    Task<VerificationCodeIssuedResponse> RequestMemberMobileCodeAsync(string mobileNumber, CancellationToken ct);
    Task<MemberMobileVerifiedResponse> VerifyMemberMobileCodeAsync(Guid challengeId, string code, CancellationToken ct);
    Task<EmailCodeIssuedResponse> RequestMemberEmailCodeAsync(string email, CancellationToken ct);
    Task<MemberEmailVerifiedResponse> VerifyMemberEmailCodeAsync(Guid challengeId, string code, CancellationToken ct);
    Task<AuthTokensResponse> SignInWithPasswordAsync(string? mobileNumber, string? password, CancellationToken ct);
    Task<AuthTokensResponse> RefreshAsync(string refreshToken, CancellationToken ct);
    Task LogoutAsync(string refreshToken, CancellationToken ct);
    Task DeleteMyAccountAsync(CancellationToken ct);
}

public sealed class AuthService(
    AppDbContext db,
    IVerificationCodeSender sender,
    IVerificationEmailSender emailSender,
    ITokenService tokens,
    SecurityKeys keys,
    IAuditLogger audit,
    ICurrentUserService currentUser,
    IOptions<PhoneVerificationOptions> verificationOptions,
    AdminPasswords passwords,
    TimeProvider clock,
    ILogger<AuthService> logger) : IAuthService
{
    private readonly PhoneVerificationOptions _options = verificationOptions.Value;

    /// <summary>How long a just-rotated refresh token may be presented again (a retry after a lost response).</summary>
    public static readonly TimeSpan RefreshRetryGrace = TimeSpan.FromMinutes(2);

    private const string InvalidCodeMessage = "The verification code has expired or is no longer valid. Please request a new code.";

    /// <summary>Shown when a deleted account's number tries to sign in or register again.</summary>
    public const string DeletedAccountMessage = "Your account is deleted. Hence can't re-register.";

    public async Task<VerificationCodeIssuedResponse> RequestVerificationCodeAsync(string mobileNumber, CancellationToken ct)
    {
        // A deleted account's number is refused before any code is sent.
        if (MobileNumber.TryNormalize(mobileNumber, out var mobile)
            && await db.Accounts.AnyAsync(a => a.MobileNumber == mobile && a.DeletedDate != null, ct))
        {
            audit.Add(AuditActions.DeletedAccountSignInBlocked, "Account", MobileNumber.Mask(mobile));
            await db.SaveChangesAsync(ct);
            throw new ForbiddenException(DeletedAccountMessage);
        }
        return await IssueCodeAsync(mobileNumber, VerificationPurposes.SignIn, accountId: null, ct);
    }

    public async Task<AuthTokensResponse> VerifyCodeAsync(Guid challengeId, string code, CancellationToken ct)
    {
        var now = clock.GetUtcNow().UtcDateTime;
        var challenge = await CheckCodeAsync(challengeId, code, VerificationPurposes.SignIn, accountId: null, now, ct);

        var (account, isNew) = await GetOrCreateAccountAsync(challenge.MobileNumber!, now, ct);
        account.LastLoginDate = now;
        account.MobileVerifiedDate = now;

        audit.Add(AuditActions.VerificationSucceeded, "Account", account.AccountId.ToString(), accountId: account.AccountId);
        var response = await IssueTokensAsync(account, isNew, ct);
        logger.LogInformation("Account {AccountId} signed in via phone verification (new: {IsNew})", account.AccountId, isNew);
        return response;
    }

    /// <summary>
    /// Sends a code to a family member's own mobile number during registration (signed-in account). The code only
    /// proves the number - it can never be used to sign in.
    /// </summary>
    public Task<VerificationCodeIssuedResponse> RequestMemberMobileCodeAsync(string mobileNumber, CancellationToken ct) =>
        IssueCodeAsync(mobileNumber, VerificationPurposes.MemberMobile, currentUser.RequireAccountId(), ct);

    /// <summary>
    /// Checks the code for a member's mobile number. The challenge then counts as proof for registering that number
    /// (see <c>RegistrationService</c>) for <see cref="VerificationPurposes.MemberMobileProofLifetime"/>.
    /// </summary>
    public async Task<MemberMobileVerifiedResponse> VerifyMemberMobileCodeAsync(Guid challengeId, string code, CancellationToken ct)
    {
        var now = clock.GetUtcNow().UtcDateTime;
        var challenge = await CheckCodeAsync(challengeId, code, VerificationPurposes.MemberMobile,
            currentUser.RequireAccountId(), now, ct);
        audit.Add(AuditActions.MemberMobileVerified, "PhoneVerificationChallenge", challengeId.ToString("N"),
            MobileNumber.Mask(challenge.MobileNumber!));
        await db.SaveChangesAsync(ct);
        return new MemberMobileVerifiedResponse(challengeId, MobileNumber.Mask(challenge.MobileNumber!));
    }

    /// <summary>
    /// Sends a code to a member's (optional) email address during registration (signed-in account). It is a separate
    /// code from the mobile number's and only proves the email address.
    /// </summary>
    public async Task<EmailCodeIssuedResponse> RequestMemberEmailCodeAsync(string emailAddress, CancellationToken ct)
    {
        if (!EmailAddress.TryNormalize(emailAddress, out var email))
            throw new RequestValidationException("email", "Please enter a valid email address.");

        var now = clock.GetUtcNow().UtcDateTime;
        await EnforceSendLimitsAsync(db.PhoneVerificationChallenges.Where(c => c.Email == email), EmailAddress.Mask(email),
            "this email address", now, ct);

        var challenge = NewChallenge(mobile: null, email, VerificationPurposes.MemberEmail, currentUser.RequireAccountId(), now,
            out var code);
        await db.SaveChangesAsync(ct);

        await emailSender.SendAsync(email, code, ct);

        return new EmailCodeIssuedResponse(
            challenge.ChallengeId,
            EmailAddress.Mask(email),
            PhoneVerificationOptions.CodeLength,
            _options.CodeLifetimeSeconds,
            _options.ResendCooldownSeconds,
            _options.ExposeCodeInResponse ? code : null);
    }

    /// <summary>
    /// Checks the email code. The challenge then counts as proof for saving that email address with the member
    /// (see <c>RegistrationService</c>) for <see cref="VerificationPurposes.MemberMobileProofLifetime"/>.
    /// </summary>
    public async Task<MemberEmailVerifiedResponse> VerifyMemberEmailCodeAsync(Guid challengeId, string code, CancellationToken ct)
    {
        var now = clock.GetUtcNow().UtcDateTime;
        var challenge = await CheckCodeAsync(challengeId, code, VerificationPurposes.MemberEmail,
            currentUser.RequireAccountId(), now, ct);
        audit.Add(AuditActions.MemberEmailVerified, "PhoneVerificationChallenge", challengeId.ToString("N"),
            EmailAddress.Mask(challenge.Email!));
        await db.SaveChangesAsync(ct);
        return new MemberEmailVerifiedResponse(challengeId, EmailAddress.Mask(challenge.Email!));
    }

    /// <summary>Issues a code for <paramref name="mobileNumber"/>: by SMS in India, on WhatsApp elsewhere.</summary>
    private async Task<VerificationCodeIssuedResponse> IssueCodeAsync(string mobileNumber, string purpose, int? accountId,
        CancellationToken ct)
    {
        if (!MobileNumber.TryNormalize(mobileNumber, out var mobile))
            throw new RequestValidationException("mobileNumber", "Please enter a valid mobile number. For a number outside India, include the country code (e.g. +971...).");

        var now = clock.GetUtcNow().UtcDateTime;

        // Store-review test login: fixed code, nothing sent, no send limits (several reviewers may sign in).
        var testCode = purpose == VerificationPurposes.SignIn && IsTestLogin(mobile) ? _options.TestLogin.Code : null;
        if (testCode is null)
            await EnforceSendLimitsAsync(db.PhoneVerificationChallenges.Where(c => c.MobileNumber == mobile), MobileNumber.Mask(mobile),
                "this number", now, ct);

        var challenge = NewChallenge(mobile, email: null, purpose, accountId, now, out var code, testCode);
        if (testCode is not null)
            audit.Add(AuditActions.TestLoginCodeIssued, "PhoneVerificationChallenge", challenge.ChallengeId.ToString("N"),
                MobileNumber.Mask(mobile));
        await db.SaveChangesAsync(ct);

        if (testCode is null) await sender.SendAsync(mobile, code, ct);
        else logger.LogInformation("Test login: code for {Mobile} not sent (fixed code)", MobileNumber.Mask(mobile));

        return new VerificationCodeIssuedResponse(
            challenge.ChallengeId,
            MobileNumber.Mask(mobile),
            PhoneVerificationOptions.CodeLength,
            _options.CodeLifetimeSeconds,
            _options.ResendCooldownSeconds,
            _options.ExposeCodeInResponse ? code : null);
    }

    /// <summary>True for the configured store-review number (<see cref="PhoneVerificationOptions.TestLogin"/>).</summary>
    private bool IsTestLogin(string mobile) => _options.TestLogin.NormalizedMobile == mobile;

    /// <summary>
    /// Adds a challenge for a mobile number or an email address (exactly one of them) with a new random code, or
    /// <paramref name="fixedCode"/> for the test login.
    /// </summary>
    private PhoneVerificationChallenge NewChallenge(string? mobile, string? email, string purpose, int? accountId, DateTime now,
        out string code, string? fixedCode = null)
    {
        var challenge = new PhoneVerificationChallenge
        {
            ChallengeId = Guid.NewGuid(),
            MobileNumber = mobile,
            Email = email,
            Purpose = purpose,
            AccountId = accountId,
            CreatedDate = now,
            ExpiresDate = now.AddSeconds(_options.CodeLifetimeSeconds),
            RequestIp = currentUser.IpAddress,
        };
        code = fixedCode ?? RandomNumberGenerator.GetInt32(0, 10_000).ToString("D4");
        challenge.CodeHash = HashCode(challenge.ChallengeId, Target(challenge), code);

        db.PhoneVerificationChallenges.Add(challenge);
        audit.Add(AuditActions.VerificationCodeRequested, "PhoneVerificationChallenge", challenge.ChallengeId.ToString("N"),
            MaskedTarget(challenge));
        return challenge;
    }

    /// <summary>What a challenge's code was sent to: the mobile number, or the email address.</summary>
    private static string Target(PhoneVerificationChallenge c) => c.MobileNumber ?? c.Email!;

    private static string MaskedTarget(PhoneVerificationChallenge c) =>
        c.MobileNumber is { } mobile ? MobileNumber.Mask(mobile) : EmailAddress.Mask(c.Email!);

    /// <summary>
    /// Checks <paramref name="code"/> and marks the challenge verified (single use). A challenge issued for another
    /// purpose or another account is treated exactly like an unknown one.
    /// </summary>
    private async Task<PhoneVerificationChallenge> CheckCodeAsync(Guid challengeId, string code, string purpose, int? accountId,
        DateTime now, CancellationToken ct)
    {
        var challenge = await db.PhoneVerificationChallenges.AsNoTracking()
            .SingleOrDefaultAsync(c => c.ChallengeId == challengeId, ct);

        if (challenge is null || challenge.Purpose != purpose || challenge.AccountId != accountId
            || challenge.VerifiedDate is not null || challenge.ExpiresDate <= now)
            throw new RequestValidationException("code", InvalidCodeMessage);

        if (challenge.FailedAttemptCount >= _options.MaxFailedAttemptsPerCode)
            throw new RequestValidationException("code", "Too many incorrect attempts. Please request a new code.");

        var expected = Convert.FromHexString(challenge.CodeHash);
        var actual = Convert.FromHexString(HashCode(challenge.ChallengeId, Target(challenge), code));
        if (!CryptographicOperations.FixedTimeEquals(expected, actual))
        {
            await RegisterFailedAttemptAsync(challenge, ct);
            var remaining = Math.Max(0, _options.MaxFailedAttemptsPerCode - challenge.FailedAttemptCount - 1);
            throw new RequestValidationException("code", remaining > 0
                ? $"The verification code is incorrect. {remaining} attempt(s) remaining."
                : "Too many incorrect attempts. Please request a new code.");
        }

        // Single use, enforced atomically: only one concurrent request can mark the challenge verified.
        var claimed = await db.PhoneVerificationChallenges
            .Where(c => c.ChallengeId == challengeId && c.VerifiedDate == null)
            .ExecuteUpdateAsync(x => x.SetProperty(c => c.VerifiedDate, now), ct);
        if (claimed == 0)
            throw new RequestValidationException("code", InvalidCodeMessage);
        return challenge;
    }

    /// <summary>
    /// Admin portal sign-in with the password a Super Admin set. Only for active accounts with an admin role. Every
    /// failure gives the same message (it never reveals whether the number exists); 5 wrong passwords in a row lock
    /// the password for 15 minutes.
    /// </summary>
    public async Task<AuthTokensResponse> SignInWithPasswordAsync(string? mobileNumber, string? password, CancellationToken ct)
    {
        const string Incorrect = "The mobile number or password is incorrect.";
        if (!MobileNumber.TryNormalize(mobileNumber, out var mobile) || string.IsNullOrEmpty(password))
            throw new UnauthorizedException(Incorrect);

        var now = clock.GetUtcNow().UtcDateTime;
        var account = await db.Accounts.SingleOrDefaultAsync(a => a.MobileNumber == mobile, ct);
        var isAdmin = account is not null && await db.AccountRoles.AnyAsync(r => r.AccountId == account.AccountId
            && r.Role.IsActive && (r.Role.Code == RoleCodes.Admin || r.Role.Code == RoleCodes.SuperAdmin), ct);
        var hash = account is { IsActive: true } && isAdmin ? account.PasswordHash : null;

        if (account?.PasswordLockedUntil > now)
        {
            var minutes = (int)Math.Ceiling((account.PasswordLockedUntil.Value - now).TotalMinutes);
            throw new UnauthorizedException($"Too many incorrect attempts. Try again in {minutes} minute(s).");
        }

        // Always hash, so a missing account or password takes as long as a wrong password.
        if (!passwords.Verify(hash, password))
        {
            if (hash is not null)
            {
                account!.FailedPasswordAttempts++;
                if (account.FailedPasswordAttempts >= AdminPasswords.MaxFailedAttempts)
                {
                    account.PasswordLockedUntil = now + AdminPasswords.Lockout;
                    account.FailedPasswordAttempts = 0;
                }
            }
            audit.Add(AuditActions.PasswordSignInFailed, "Account", MobileNumber.Mask(mobile), accountId: account?.AccountId);
            await db.SaveChangesAsync(ct);
            throw new UnauthorizedException(Incorrect);
        }

        account!.FailedPasswordAttempts = 0;
        account.PasswordLockedUntil = null;
        account.LastLoginDate = now;
        audit.Add(AuditActions.PasswordSignInSucceeded, "Account", account.AccountId.ToString(), accountId: account.AccountId);
        var response = await IssueTokensAsync(account, isNewAccount: false, ct);
        logger.LogInformation("Account {AccountId} signed in to the admin portal with a password", account.AccountId);
        return response;
    }

    public async Task<AuthTokensResponse> RefreshAsync(string refreshToken, CancellationToken ct)
    {
        var now = clock.GetUtcNow().UtcDateTime;
        var hash = tokens.HashRefreshToken(refreshToken);
        var stored = await db.RefreshTokens.Include(t => t.Account).SingleOrDefaultAsync(t => t.TokenHash == hash, ct);

        if (stored is null)
            throw new UnauthorizedException("Your session has expired. Please sign in again.");

        if (stored.RevokedDate is not null && stored.ReplacedByTokenHash is not null
            && now - stored.RevokedDate.Value <= RefreshRetryGrace)
        {
            // The app retried a refresh whose response it never received (weak network): its replacement was
            // never used. Replace that unused token instead of treating the retry as theft.
            var unused = await db.RefreshTokens.SingleOrDefaultAsync(
                t => t.TokenHash == stored.ReplacedByTokenHash && t.RevokedDate == null, ct);
            if (unused is not null)
            {
                unused.RevokedDate = now;
                return await IssueTokensAsync(stored.Account, isNewAccount: false, ct, replaced: stored);
            }
        }

        if (stored.RevokedDate is not null)
        {
            // A rotated token was presented again: treat as theft and end every session of the account.
            await db.RefreshTokens
                .Where(t => t.AccountId == stored.AccountId && t.RevokedDate == null)
                .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedDate, now), ct);
            audit.Add(AuditActions.RefreshTokenReuseDetected, "Account", stored.AccountId.ToString(), accountId: stored.AccountId);
            await db.SaveChangesAsync(ct);
            logger.LogWarning("Refresh token reuse detected for account {AccountId}; all sessions revoked", stored.AccountId);
            throw new UnauthorizedException("Your session has expired. Please sign in again.");
        }

        if (stored.ExpiresDate <= now || !stored.Account.IsActive)
            throw new UnauthorizedException("Your session has expired. Please sign in again.");

        stored.RevokedDate = now;
        var response = await IssueTokensAsync(stored.Account, isNewAccount: false, ct, replaced: stored);
        return response;
    }

    public async Task LogoutAsync(string refreshToken, CancellationToken ct)
    {
        var accountId = currentUser.RequireAccountId();
        var hash = tokens.HashRefreshToken(refreshToken);
        var now = clock.GetUtcNow().UtcDateTime;

        await db.RefreshTokens
            .Where(t => t.TokenHash == hash && t.AccountId == accountId && t.RevokedDate == null)
            .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedDate, now), ct);
        audit.Add(AuditActions.LoggedOut, "Account", accountId.ToString());
        await db.SaveChangesAsync(ct);
    }

    /// <summary>
    /// "Delete my account": marks the signed-in account deleted and its members inactive, and ends every session.
    /// No data is removed (kept for the records); the number can never sign in or register again.
    /// </summary>
    public Task DeleteMyAccountAsync(CancellationToken ct)
    {
        var accountId = currentUser.RequireAccountId();
        var strategy = db.Database.CreateExecutionStrategy();
        return strategy.ExecuteAsync(async () =>
        {
            db.ChangeTracker.Clear();
            var now = clock.GetUtcNow().UtcDateTime;
            await using var transaction = await db.Database.BeginTransactionAsync(ct);

            var account = await db.Accounts.SingleAsync(a => a.AccountId == accountId, ct);
            if (account.IsDeleted) return;
            // The store-review account must keep working after a reviewer tries "Delete account": its members and
            // sessions are closed as usual, but the number is not blocked.
            var testLogin = IsTestLogin(account.MobileNumber);
            if (!testLogin)
            {
                account.DeletedDate = now;
                account.IsActive = false;
            }

            var members = await db.Members.Where(m => m.AccountId == accountId && m.IsActive).ToListAsync(ct);
            foreach (var member in members) member.IsActive = false;

            await db.RefreshTokens
                .Where(t => t.AccountId == accountId && t.RevokedDate == null)
                .ExecuteUpdateAsync(s => s.SetProperty(t => t.RevokedDate, now), ct);

            audit.Add(AuditActions.AccountDeleted, "Account", accountId.ToString(),
                $"{members.Count} member(s) deactivated; data kept{(testLogin ? "; test login - number not blocked" : "")}",
                accountId: accountId);
            await db.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            logger.LogInformation("Account {AccountId} deleted by its user ({Members} members kept inactive)", accountId, members.Count);
        });
    }

    /// <summary>Cooldown and hourly limit for one mobile number or email address (<paramref name="sameTarget"/>).</summary>
    private async Task EnforceSendLimitsAsync(IQueryable<PhoneVerificationChallenge> sameTarget, string maskedTarget,
        string targetText, DateTime now, CancellationToken ct)
    {
        var windowStart = now.AddHours(-1);
        var recent = await sameTarget.AsNoTracking()
            .Where(c => c.CreatedDate >= windowStart)
            .Select(c => c.CreatedDate)
            .OrderByDescending(d => d)
            .ToListAsync(ct);

        if (recent.Count > 0)
        {
            var nextAllowed = recent[0].AddSeconds(_options.ResendCooldownSeconds);
            if (nextAllowed > now)
            {
                var wait = (int)Math.Ceiling((nextAllowed - now).TotalSeconds);
                throw new TooManyRequestsException($"Please wait {wait} seconds before requesting another code.", wait);
            }
        }

        if (recent.Count >= _options.MaxCodesPerHourPerNumber)
        {
            var wait = (int)Math.Ceiling((recent[^1].AddHours(1) - now).TotalSeconds);
            logger.LogWarning("Verification code send limit reached for {Target}", maskedTarget);
            throw new TooManyRequestsException($"Too many verification codes requested for {targetText}. Please try again later.", wait);
        }
    }

    private async Task RegisterFailedAttemptAsync(PhoneVerificationChallenge challenge, CancellationToken ct)
    {
        await db.PhoneVerificationChallenges
            .Where(c => c.ChallengeId == challenge.ChallengeId)
            .ExecuteUpdateAsync(s => s.SetProperty(c => c.FailedAttemptCount, c => c.FailedAttemptCount + 1), ct);
        audit.Add(AuditActions.VerificationFailed, "PhoneVerificationChallenge", challenge.ChallengeId.ToString("N"),
            MaskedTarget(challenge));
        await db.SaveChangesAsync(ct);
        logger.LogWarning("Incorrect verification code for {Target}", MaskedTarget(challenge));
    }

    private async Task<(Account Account, bool IsNew)> GetOrCreateAccountAsync(string mobile, DateTime now, CancellationToken ct)
    {
        var account = await db.Accounts.SingleOrDefaultAsync(a => a.MobileNumber == mobile, ct);
        if (account is not null)
        {
            if (account.IsDeleted) throw new ForbiddenException(DeletedAccountMessage);
            if (!account.IsActive)
                throw new ForbiddenException("This account has been deactivated. Please contact the Sangha office.");
            return (account, false);
        }

        var memberRoleId = await db.Roles.Where(r => r.Code == RoleCodes.Member).Select(r => r.Id).SingleAsync(ct);
        account = new Account { MobileNumber = mobile, MobileVerifiedDate = now };
        account.AccountRoles.Add(new AccountRole { RoleId = memberRoleId, CreatedDate = now, CreatedBy = "system" });
        db.Accounts.Add(account);

        try
        {
            await db.SaveChangesAsync(ct);
        }
        catch (DbUpdateException)
        {
            // Another request created the same account concurrently; use that one.
            db.ChangeTracker.Clear();
            account = await db.Accounts.SingleAsync(a => a.MobileNumber == mobile, ct);
            return (account, false);
        }

        audit.Add(AuditActions.AccountCreated, "Account", account.AccountId.ToString(), accountId: account.AccountId);
        return (account, true);
    }

    private async Task<AuthTokensResponse> IssueTokensAsync(Account account, bool isNewAccount, CancellationToken ct,
        RefreshToken? replaced = null)
    {
        var roles = await db.AccountRoles
            .Where(r => r.AccountId == account.AccountId && r.Role.IsActive)
            .Select(r => r.Role.Code)
            .ToListAsync(ct);

        var access = tokens.CreateAccessToken(account.AccountId, roles);
        var refresh = tokens.CreateRefreshToken();
        db.RefreshTokens.Add(new RefreshToken
        {
            AccountId = account.AccountId,
            TokenHash = refresh.TokenHash,
            ExpiresDate = refresh.ExpiresAt,
            CreatedDate = clock.GetUtcNow().UtcDateTime,
            CreatedByIp = currentUser.IpAddress,
        });
        if (replaced is not null)
        {
            replaced.ReplacedByTokenHash = refresh.TokenHash;
            audit.Add(AuditActions.TokenRefreshed, "Account", account.AccountId.ToString(), accountId: account.AccountId);
        }

        await db.SaveChangesAsync(ct);

        var memberCount = await db.Members.CountAsync(m => m.AccountId == account.AccountId && m.IsActive, ct);
        return new AuthTokensResponse(access.Token, access.ExpiresAt, refresh.Token, refresh.ExpiresAt, isNewAccount, memberCount);
    }

    private string HashCode(Guid challengeId, string target, string code)
    {
        using var hmac = new HMACSHA256(keys.CodeHashingKey);
        return Convert.ToHexString(hmac.ComputeHash(Encoding.UTF8.GetBytes($"{challengeId:N}:{target}:{code}")));
    }
}
