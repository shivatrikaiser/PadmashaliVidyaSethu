using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;

namespace PadmashaliVidyaSetu.Api.Services.Members;

public interface IRegistrationIdGenerator
{
    /// <summary>Allocates the next ID for the temple. Must be called inside the registration transaction.</summary>
    Task<string> NextAsync(int templeId, string templeCode, CancellationToken ct);
}

/// <summary>
/// Format: PVS-TT-NNNN — TT is the temple's 2-digit code, NNNN a 4-digit sequence continuous within the temple.
/// Allocation is a single atomic MERGE on TempleRegistrationSequences, so concurrent registrations for the same
/// temple can never receive the same number. If the surrounding transaction rolls back the number is released too.
/// </summary>
public sealed class RegistrationIdGenerator(AppDbContext db) : IRegistrationIdGenerator
{
    public const int MaxSequence = 9999;

    public async Task<string> NextAsync(int templeId, string templeCode, CancellationToken ct)
    {
        var next = await db.Database.SqlQuery<int>($"""
            MERGE dbo.TempleRegistrationSequences WITH (HOLDLOCK) AS target
            USING (SELECT {templeId} AS TempleId) AS source
               ON target.TempleId = source.TempleId
            WHEN MATCHED AND target.LastSequenceNumber < {MaxSequence} THEN
                UPDATE SET LastSequenceNumber = target.LastSequenceNumber + 1
            WHEN NOT MATCHED THEN
                INSERT (TempleId, LastSequenceNumber) VALUES (source.TempleId, 1)
            OUTPUT inserted.LastSequenceNumber AS [Value];
            """).ToListAsync(ct);

        if (next.Count == 0)
            throw new BusinessRuleException(
                "Registrations for this temple have reached the maximum number. Please contact the Sangha office.");

        return Format(templeCode, next[0]);
    }

    public static string Format(string templeCode, int sequence) => $"PVS-{templeCode}-{sequence:D4}";
}
