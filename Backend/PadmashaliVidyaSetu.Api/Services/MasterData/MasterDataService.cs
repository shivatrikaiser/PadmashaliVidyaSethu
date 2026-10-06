using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Common;

namespace PadmashaliVidyaSetu.Api.Services.MasterData;

public interface IMasterDataService
{
    IReadOnlyCollection<string> SupportedTypes { get; }
    Task<IReadOnlyList<MasterDataItemDto>> GetAsync(string type, CancellationToken ct);
    Task<IReadOnlyDictionary<string, IReadOnlyList<MasterDataItemDto>>> GetManyAsync(IEnumerable<string> types, CancellationToken ct);
    Task<IReadOnlyList<MasterDataItemDto>> GetStatesAsync(int countryId, CancellationToken ct);
    Task<IReadOnlyList<MasterDataItemDto>> GetDistrictsAsync(int stateId, CancellationToken ct);
    Task<IReadOnlyList<MasterDataItemDto>> GetTaluksAsync(int districtId, CancellationToken ct);
}

/// <summary>
/// Serves every configurable dropdown list. The Flutter app never hard-codes these values; it asks for a list by
/// its type key (e.g. "temples") and uses <see cref="MasterDataItemDto.Code"/> only for the few rules that
/// depend on a specific value (e.g. STUDENT shows "Class Studying").
/// </summary>
public sealed class MasterDataService(AppDbContext db) : IMasterDataService
{
    private static readonly Dictionary<string, Func<AppDbContext, IQueryable<MasterDataEntity>>> Registry =
        new(StringComparer.OrdinalIgnoreCase)
        {
            ["temples"] = d => d.Temples,
            ["organisations"] = d => d.Organisations,
            ["genders"] = d => d.Genders,
            ["member-statuses"] = d => d.MemberStatuses,
            ["classes"] = d => d.Classes,
            ["education-levels"] = d => d.EducationLevels,
            ["courses"] = d => d.Courses,
            ["branches"] = d => d.Branches,
            ["boards"] = d => d.Boards,
            ["universities"] = d => d.Universities,
            ["career-options"] = d => d.CareerOptions,
            ["interest-areas"] = d => d.InterestAreas,
            ["skills"] = d => d.Skills,
            ["sports"] = d => d.Sports,
            ["hobbies"] = d => d.Hobbies,
            ["competitive-exams"] = d => d.CompetitiveExams,
            ["achievement-types"] = d => d.AchievementTypes,
            ["disability-types"] = d => d.DisabilityTypes,
            ["communication-topics"] = d => d.CommunicationTopics,
            ["communication-channels"] = d => d.CommunicationChannels,
            ["countries"] = d => d.Countries,
        };

    public IReadOnlyCollection<string> SupportedTypes => Registry.Keys;

    public async Task<IReadOnlyList<MasterDataItemDto>> GetAsync(string type, CancellationToken ct)
    {
        if (!Registry.TryGetValue(type, out var source))
            throw new NotFoundException($"Unknown list '{type}'.");
        return await Project(source(db)).ToListAsync(ct);
    }

    public async Task<IReadOnlyDictionary<string, IReadOnlyList<MasterDataItemDto>>> GetManyAsync(
        IEnumerable<string> types, CancellationToken ct)
    {
        var result = new Dictionary<string, IReadOnlyList<MasterDataItemDto>>(StringComparer.OrdinalIgnoreCase);
        foreach (var type in types.Select(t => t.Trim()).Where(t => t.Length > 0).Distinct(StringComparer.OrdinalIgnoreCase))
        {
            result[type] = await GetAsync(type, ct);
        }
        return result;
    }

    public async Task<IReadOnlyList<MasterDataItemDto>> GetStatesAsync(int countryId, CancellationToken ct) =>
        await Project(db.States.Where(s => s.CountryId == countryId)).ToListAsync(ct);

    public async Task<IReadOnlyList<MasterDataItemDto>> GetDistrictsAsync(int stateId, CancellationToken ct) =>
        await Project(db.Districts.Where(d => d.StateId == stateId)).ToListAsync(ct);

    public async Task<IReadOnlyList<MasterDataItemDto>> GetTaluksAsync(int districtId, CancellationToken ct) =>
        await Project(db.Taluks.Where(t => t.DistrictId == districtId)).ToListAsync(ct);

    private static IQueryable<MasterDataItemDto> Project(IQueryable<MasterDataEntity> query) =>
        query.AsNoTracking()
            .Where(e => e.IsActive)
            .OrderBy(e => e.DisplayOrder).ThenBy(e => e.Name)
            .Select(e => new MasterDataItemDto(e.Id, e.Name, e.Code));
}
