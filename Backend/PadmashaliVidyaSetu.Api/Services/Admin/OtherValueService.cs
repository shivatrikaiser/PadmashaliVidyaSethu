using Microsoft.Data.SqlClient;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Logging;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface IOtherValueService
{
    Task<IReadOnlyList<OtherValueDto>> GetPendingAsync(CancellationToken ct);
    Task<MapOtherValueResultDto> MapAsync(MapOtherValueRequest request, CancellationToken ct);
}

/// <summary>
/// "Other" texts typed by members (see Docs/MasterData.md). An administrator creates the proper list entry (master
/// lists page) and maps the text to it: every member who typed it is moved from OTHER to that entry and the text
/// is cleared.
/// </summary>
// Table / column names in the SQL below come only from the constant Sources table; member text and ids are parameters.
#pragma warning disable EF1002, EF1003
public sealed class OtherValueService(
    AppDbContext db,
    IAdminListService lists,
    ICurrentUserService currentUser,
    IAuditLogger audit) : IOtherValueService
{
    /// <summary>Where "Other" texts are stored. All identifiers are constants (never user input).</summary>
    private static readonly OtherSource[] Sources =
    [
        new("education-levels", "Education Levels", "PVS_Members", "HighestEducationLevelId", "HighestEducationLevelOtherText"),
        new("education-levels", "Education Levels", "PVS_MemberEducation", "EducationLevelId", "EducationLevelOtherText"),
        new("courses", "Courses", "PVS_MemberEducation", "CourseId", "CourseOtherText"),
        new("branches", "Branches", "PVS_MemberEducation", "BranchId", "BranchOtherText"),
        new("boards", "Boards", "PVS_MemberEducation", "BoardId", "BoardOtherText"),
        new("skills", "Skills", "PVS_MemberSkills", "SkillId", "OtherText", IsLink: true),
        new("interest-areas", "Interest Areas", "PVS_MemberInterestAreas", "InterestAreaId", "OtherText", IsLink: true),
        new("sports", "Sports", "PVS_MemberSports", "SportId", "OtherText", IsLink: true),
        new("hobbies", "Hobbies", "PVS_MemberHobbies", "HobbyId", "OtherText", IsLink: true),
        new("career-options", "Career Options", "PVS_MemberCareerAspirations", "CareerOptionId", "OtherText", IsLink: true),
        new("competitive-exams", "Competitive Exams", "PVS_MemberCompetitiveExams", "CompetitiveExamId", "OtherText", IsLink: true),
        new("achievement-types", "Achievement Types", "PVS_AcademicAchievements", "AchievementTypeId", "AchievementTypeOtherText"),
        new("disability-types", "Disability Types", "PVS_MemberDisabilities", "DisabilityTypeId", "OtherText", IsLink: true, Sensitive: true),
    ];

    public async Task<IReadOnlyList<OtherValueDto>> GetPendingAsync(CancellationToken ct)
    {
        var result = new Dictionary<(string Type, string Text), OtherValueDto>();
        foreach (var source in VisibleSources())
        {
            var rows = await db.Database.SqlQueryRaw<OtherRow>(
                    $"SELECT [{source.TextColumn}] AS [Text], COUNT(*) AS [Count] FROM [dbo].[{source.Table}] " +
                    $"WHERE [{source.TextColumn}] IS NOT NULL GROUP BY [{source.TextColumn}]")
                .ToListAsync(ct);
            foreach (var row in rows)
            {
                var key = (source.ListType, row.Text.ToUpperInvariant());
                result[key] = result.TryGetValue(key, out var existing)
                    ? existing with { MemberCount = existing.MemberCount + row.Count }
                    : new OtherValueDto(source.ListType, source.ListLabel, row.Text, row.Count);
            }
        }
        return result.Values.OrderBy(v => v.ListLabel).ThenByDescending(v => v.MemberCount).ThenBy(v => v.Text).ToList();
    }

    public async Task<MapOtherValueResultDto> MapAsync(MapOtherValueRequest request, CancellationToken ct)
    {
        var type = request.ListType.Tidy();
        var text = request.Text.Tidy();
        var sources = VisibleSources().Where(s => s.ListType.Equals(type, StringComparison.OrdinalIgnoreCase)).ToList();
        if (sources.Count == 0) throw new NotFoundException($"Unknown list '{type}'.");
        if (text.Length == 0) throw new RequestValidationException([new ApiError("text", "The text to map is missing.")]);

        var target = await lists.FindMappableAsync(type, request.TargetId, ct)
                     ?? throw new RequestValidationException([new ApiError("targetId", "Choose an active list entry other than \"Other\".")]);

        // The retry policy needs the whole transaction to run inside the execution strategy.
        var updated = await db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
        {
            var rows = 0;
            await using var transaction = await db.Database.BeginTransactionAsync(ct);
            foreach (var s in sources)
            {
                if (s.IsLink)
                {
                    // A member who already has the target entry: drop the now-duplicate "Other" row (key is member + entry).
                    rows += await db.Database.ExecuteSqlRawAsync(
                        $"DELETE o FROM [dbo].[{s.Table}] o WHERE o.[{s.TextColumn}] = @text AND EXISTS " +
                        $"(SELECT 1 FROM [dbo].[{s.Table}] x WHERE x.[RegistrationId] = o.[RegistrationId] AND x.[{s.KeyColumn}] = @target)",
                        Parameters(text, target.Id), ct);
                }
                rows += await db.Database.ExecuteSqlRawAsync(
                    $"UPDATE [dbo].[{s.Table}] SET [{s.KeyColumn}] = @target, [{s.TextColumn}] = NULL WHERE [{s.TextColumn}] = @text",
                    Parameters(text, target.Id), ct);
            }

            audit.Add(AuditActions.OtherValueMapped, type, target.Code, $"'{text}' -> '{target.Name}' ({rows} rows)");
            await db.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            return rows;
        });
        return new MapOtherValueResultDto(updated);
    }

    private IEnumerable<OtherSource> VisibleSources() =>
        currentUser.IsInRole(RoleCodes.SuperAdmin) ? Sources : Sources.Where(s => !s.Sensitive);

    private static SqlParameter[] Parameters(string text, int targetId) =>
        [new SqlParameter("@text", text), new SqlParameter("@target", targetId)];

    private sealed record OtherSource(string ListType, string ListLabel, string Table, string KeyColumn, string TextColumn,
        bool IsLink = false, bool Sensitive = false);

    private sealed class OtherRow
    {
        public string Text { get; set; } = string.Empty;
        public int Count { get; set; }
    }
}
#pragma warning restore EF1002, EF1003
