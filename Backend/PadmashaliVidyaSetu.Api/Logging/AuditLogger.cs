using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.Entities.Compliance;

namespace PadmashaliVidyaSetu.Api.Logging;

public interface IAuditLogger
{
    /// <summary>
    /// Adds an audit row to the current unit of work (saved with the caller's SaveChanges, so the audit entry
    /// commits or rolls back together with the change it describes).
    /// Never pass verification codes, tokens or sensitive personal data in <paramref name="details"/>.
    /// </summary>
    void Add(string action, string? entityName = null, string? entityKey = null, string? details = null, int? accountId = null);
}

public sealed class AuditLogger(AppDbContext db, ICurrentUserService currentUser, TimeProvider clock,
    ILogger<AuditLogger> logger) : IAuditLogger
{
    public void Add(string action, string? entityName = null, string? entityKey = null, string? details = null, int? accountId = null)
    {
        var actor = accountId ?? currentUser.AccountId;
        db.AuditLogs.Add(new AuditLog
        {
            AccountId = actor,
            Action = action,
            EntityName = entityName,
            EntityKey = entityKey,
            Details = details is { Length: > 1000 } ? details[..1000] : details,
            IpAddress = currentUser.IpAddress,
            CreatedDate = clock.GetUtcNow().UtcDateTime,
        });

        logger.LogInformation("Audit {AuditAction} {EntityName} {EntityKey} by account {AccountId}",
            action, entityName, entityKey, actor);
    }
}
