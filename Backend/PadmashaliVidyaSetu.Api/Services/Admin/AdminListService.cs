using System.Text.RegularExpressions;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Logging;
using PadmashaliVidyaSetu.Api.Services.Locations;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface IAdminListService
{
    IReadOnlyList<AdminListTypeDto> ListTypes { get; }
    bool IsKnown(string type);
    Task<IReadOnlyList<AdminListItemDto>> GetItemsAsync(string type, CancellationToken ct);
    Task<AdminListItemDto> CreateAsync(string type, CreateListItemRequest request, CancellationToken ct);
    Task<AdminListItemDto> UpdateAsync(string type, int id, UpdateListItemRequest request, CancellationToken ct);
    /// <summary>The active, non-"Other" entry <paramref name="id"/> of the list, or null.</summary>
    Task<MasterDataEntity?> FindMappableAsync(string type, int id, CancellationToken ct);
}

/// <summary>
/// Add / rename / reorder / deactivate entries of the configurable lists. Codes never change (they are stable keys);
/// codes the application relies on (STUDENT, OTHER, ...) cannot be deactivated.
/// </summary>
public sealed partial class AdminListService(AppDbContext db, IAuditLogger audit) : IAdminListService
{
    private static readonly HashSet<string> CommonProtectedCodes = [MasterCodes.Other];

    private static readonly Dictionary<string, ListDefinition> Lists = new(StringComparer.OrdinalIgnoreCase)
    {
        ["temples"] = new("Temples", new ListOps<Temple>(d => d.Temples), NameLength: 200, TempleCode: true),
        ["organisations"] = new("Organisations", new ListOps<Organisation>(d => d.Organisations), Protected: [MasterCodes.OrganisationNone]),
        ["genders"] = new("Genders", new ListOps<Gender>(d => d.Genders)),
        ["member-statuses"] = new("Current Status", new ListOps<MemberStatus>(d => d.MemberStatuses),
            Protected: [MasterCodes.StatusStudent, MasterCodes.StatusWorking, MasterCodes.StatusUnemployed]),
        ["classes"] = new("Class Studying", new ListOps<SchoolClass>(d => d.Classes)),
        ["education-levels"] = new("Education Levels", new ListOps<EducationLevel>(d => d.EducationLevels)),
        ["courses"] = new("Courses", new ListOps<Course>(d => d.Courses)),
        ["branches"] = new("Branches", new ListOps<Branch>(d => d.Branches)),
        ["boards"] = new("Boards", new ListOps<Board>(d => d.Boards)),
        ["universities"] = new("Universities", new ListOps<University>(d => d.Universities)),
        ["career-options"] = new("Career Options", new ListOps<CareerOption>(d => d.CareerOptions)),
        ["interest-areas"] = new("Interest Areas", new ListOps<InterestArea>(d => d.InterestAreas)),
        ["skills"] = new("Skills", new ListOps<Skill>(d => d.Skills)),
        ["sports"] = new("Sports", new ListOps<Sport>(d => d.Sports)),
        ["hobbies"] = new("Hobbies", new ListOps<Hobby>(d => d.Hobbies)),
        ["competitive-exams"] = new("Competitive Exams", new ListOps<CompetitiveExam>(d => d.CompetitiveExams)),
        ["achievement-types"] = new("Achievement Types", new ListOps<AchievementType>(d => d.AchievementTypes)),
        ["disability-types"] = new("Disability Types", new ListOps<DisabilityType>(d => d.DisabilityTypes)),
        ["communication-topics"] = new("Communication Topics", new ListOps<CommunicationTopic>(d => d.CommunicationTopics)),
        ["communication-channels"] = new("Communication Channels", new ListOps<CommunicationChannel>(d => d.CommunicationChannels)),
    };

    public IReadOnlyList<AdminListTypeDto> ListTypes { get; } =
        Lists.Select(l => new AdminListTypeDto(l.Key, l.Value.Label)).ToList();

    public bool IsKnown(string type) => Lists.ContainsKey(type);

    public async Task<IReadOnlyList<AdminListItemDto>> GetItemsAsync(string type, CancellationToken ct)
    {
        var list = Get(type);
        var items = await list.Ops.Query(db).AsNoTracking()
            .OrderBy(e => e.DisplayOrder).ThenBy(e => e.Name)
            .ToListAsync(ct);
        return items.Select(e => ToDto(list, e)).ToList();
    }

    public async Task<AdminListItemDto> CreateAsync(string type, CreateListItemRequest request, CancellationToken ct)
    {
        var list = Get(type);
        var name = ValidName(list, request.Name);
        await EnsureNameFreeAsync(list, name, null, ct);

        string code;
        if (list.TempleCode)
        {
            code = request.Code.Tidy();
            if (!TempleCodePattern().IsMatch(code))
                throw Invalid("code", "Temple code must be exactly 2 digits (e.g. 17). It becomes part of every Registration ID.");
            if (await list.Ops.Query(db).AnyAsync(e => e.Code == code, ct))
                throw new ConflictException($"Temple code {code} is already used.");
        }
        else
        {
            code = await list.Ops.UniqueCodeAsync(db, LocationResolver.Slug(name), ct);
        }

        var order = request.DisplayOrder ?? await DefaultOrderAsync(list, ct);
        var entity = list.Ops.Add(db, name, code, order);
        audit.Add(AuditActions.ListItemCreated, type, code, name);
        await db.SaveChangesAsync(ct);
        return ToDto(list, entity);
    }

    public async Task<AdminListItemDto> UpdateAsync(string type, int id, UpdateListItemRequest request, CancellationToken ct)
    {
        var list = Get(type);
        var entity = await list.Ops.Query(db).SingleOrDefaultAsync(e => e.Id == id, ct)
                     ?? throw new NotFoundException("List entry not found.");

        var changes = new List<string>();
        if (request.Name is not null)
        {
            var name = ValidName(list, request.Name);
            if (name != entity.Name)
            {
                await EnsureNameFreeAsync(list, name, id, ct);
                changes.Add($"name '{entity.Name}' -> '{name}'");
                entity.Name = name;
            }
        }
        if (request.DisplayOrder is { } order && order != entity.DisplayOrder)
        {
            changes.Add($"order {entity.DisplayOrder} -> {order}");
            entity.DisplayOrder = order;
        }
        if (request.IsActive is { } active && active != entity.IsActive)
        {
            if (!active && IsProtected(list, entity.Code))
                throw new BusinessRuleException($"'{entity.Name}' is used by the application and cannot be deactivated. You can rename it.");
            changes.Add(active ? "activated" : "deactivated");
            entity.IsActive = active;
        }

        if (changes.Count > 0)
        {
            audit.Add(AuditActions.ListItemUpdated, type, entity.Code, string.Join("; ", changes));
            await db.SaveChangesAsync(ct);
        }
        return ToDto(list, entity);
    }

    public async Task<MasterDataEntity?> FindMappableAsync(string type, int id, CancellationToken ct) =>
        await Get(type).Ops.Query(db).AsNoTracking()
            .SingleOrDefaultAsync(e => e.Id == id && e.IsActive && e.Code != MasterCodes.Other, ct);

    private ListDefinition Get(string type) =>
        Lists.TryGetValue(type, out var list) ? list : throw new NotFoundException($"Unknown list '{type}'.");

    private static string ValidName(ListDefinition list, string? value)
    {
        var name = value.Tidy();
        if (name.Length < 2) throw Invalid("name", "Please enter a name (at least 2 characters).");
        if (name.Length > list.NameLength) throw Invalid("name", $"The name can be at most {list.NameLength} characters.");
        return name;
    }

    private async Task EnsureNameFreeAsync(ListDefinition list, string name, int? exceptId, CancellationToken ct)
    {
        if (await list.Ops.Query(db).AnyAsync(e => e.Name == name && e.Id != exceptId, ct))
            throw new ConflictException($"'{name}' already exists in this list.");
    }

    /// <summary>New entries go just before "Other", or at the end when the list has no "Other".</summary>
    private async Task<int> DefaultOrderAsync(ListDefinition list, CancellationToken ct)
    {
        var query = list.Ops.Query(db);
        var other = await query.Where(e => e.Code == MasterCodes.Other).Select(e => (int?)e.DisplayOrder).FirstOrDefaultAsync(ct);
        var lastBeforeOther = await query.Where(e => e.Code != MasterCodes.Other).MaxAsync(e => (int?)e.DisplayOrder, ct) ?? 0;
        return other is { } o ? Math.Min(lastBeforeOther + 1, o - 1) : lastBeforeOther + 10;
    }

    private static bool IsProtected(ListDefinition list, string code) =>
        CommonProtectedCodes.Contains(code) || (list.Protected?.Contains(code) ?? false);

    private static AdminListItemDto ToDto(ListDefinition list, MasterDataEntity e) =>
        new(e.Id, e.Name, e.Code, e.DisplayOrder, e.IsActive, IsProtected(list, e.Code));

    private static RequestValidationException Invalid(string field, string message) => new([new ApiError(field, message)]);

    [GeneratedRegex(@"^\d{2}$")]
    private static partial Regex TempleCodePattern();

    private sealed record ListDefinition(string Label, IListOps Ops, int NameLength = 150, bool TempleCode = false,
        string[]? Protected = null);

    private interface IListOps
    {
        IQueryable<MasterDataEntity> Query(AppDbContext db);
        Task<string> UniqueCodeAsync(AppDbContext db, string baseCode, CancellationToken ct);
        MasterDataEntity Add(AppDbContext db, string name, string code, int displayOrder);
    }

    private sealed class ListOps<T>(Func<AppDbContext, DbSet<T>> set) : IListOps where T : MasterDataEntity, new()
    {
        public IQueryable<MasterDataEntity> Query(AppDbContext db) => set(db);

        public Task<string> UniqueCodeAsync(AppDbContext db, string baseCode, CancellationToken ct) =>
            LocationResolver.UniqueCodeAsync(set(db), baseCode.Length == 0 ? "ITEM" : baseCode, ct);

        public MasterDataEntity Add(AppDbContext db, string name, string code, int displayOrder)
        {
            var entity = new T { Name = name, Code = code, DisplayOrder = displayOrder, IsActive = true };
            set(db).Add(entity);
            return entity;
        }
    }
}
