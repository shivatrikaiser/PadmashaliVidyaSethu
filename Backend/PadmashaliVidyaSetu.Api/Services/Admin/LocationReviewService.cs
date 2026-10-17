using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Locations;
using PadmashaliVidyaSetu.Api.Logging;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface ILocationReviewService
{
    Task<IReadOnlyList<LocationReviewItemDto>> GetAsync(bool includeSeed, CancellationToken ct);
    Task UpdateDistrictAsync(int id, UpdateLocationRequest request, CancellationToken ct);
    Task UpdateTalukAsync(int id, UpdateLocationRequest request, CancellationToken ct);
    Task<int> MergeTalukAsync(int sourceId, int targetId, CancellationToken ct);
}

/// <summary>
/// Districts and taluks added at runtime - by PIN-code lookups or typed by members ("My taluk is not listed").
/// Administrators rename them, deactivate them, or merge a duplicate taluk into the correct one.
/// </summary>
public sealed class LocationReviewService(AppDbContext db, IAuditLogger audit) : ILocationReviewService
{
    public async Task<IReadOnlyList<LocationReviewItemDto>> GetAsync(bool includeSeed, CancellationToken ct)
    {
        var districts = await db.Districts.AsNoTracking()
            .Where(d => includeSeed || d.Source != LocationSources.Seed)
            .Select(d => new LocationReviewItemDto("District", d.Id, d.Name, d.StateId, d.State.Name, d.Source, d.IsActive,
                db.MemberAddresses.Count(a => a.DistrictId == d.Id), d.CreatedDate))
            .ToListAsync(ct);
        var taluks = await db.Taluks.AsNoTracking()
            .Where(t => includeSeed || t.Source != LocationSources.Seed)
            .Select(t => new LocationReviewItemDto("Taluk", t.Id, t.Name, t.DistrictId, t.District.Name, t.Source, t.IsActive,
                db.MemberAddresses.Count(a => a.TalukId == t.Id), t.CreatedDate))
            .ToListAsync(ct);

        return districts.Concat(taluks)
            .OrderByDescending(l => l.CreatedDate).ThenBy(l => l.Kind).ThenBy(l => l.Name)
            .ToList();
    }

    public Task UpdateDistrictAsync(int id, UpdateLocationRequest request, CancellationToken ct) =>
        UpdateAsync(db.Districts, "District", id, request,
            (d, name) => db.Districts.AnyAsync(x => x.StateId == d.StateId && x.Name == name && x.Id != d.Id, ct), ct);

    public Task UpdateTalukAsync(int id, UpdateLocationRequest request, CancellationToken ct) =>
        UpdateAsync(db.Taluks, "Taluk", id, request,
            (t, name) => db.Taluks.AnyAsync(x => x.DistrictId == t.DistrictId && x.Name == name && x.Id != t.Id, ct), ct);

    public async Task<int> MergeTalukAsync(int sourceId, int targetId, CancellationToken ct)
    {
        if (sourceId == targetId) throw new BusinessRuleException("Choose a different taluk to merge into.");
        var source = await db.Taluks.SingleOrDefaultAsync(t => t.Id == sourceId, ct) ?? throw new NotFoundException("Taluk not found.");
        var target = await db.Taluks.SingleOrDefaultAsync(t => t.Id == targetId && t.IsActive, ct)
                     ?? throw new RequestValidationException([new ApiError("targetTalukId", "Choose an active taluk.")]);
        if (target.DistrictId != source.DistrictId)
            throw new RequestValidationException([new ApiError("targetTalukId", "Both taluks must be in the same district.")]);

        return await db.Database.CreateExecutionStrategy().ExecuteAsync(async () =>
        {
            await using var transaction = await db.Database.BeginTransactionAsync(ct);
            var moved = await db.MemberAddresses.Where(a => a.TalukId == sourceId)
                .ExecuteUpdateAsync(a => a.SetProperty(x => x.TalukId, targetId), ct);
            await db.Cities.Where(c => c.TalukId == sourceId)
                .ExecuteUpdateAsync(c => c.SetProperty(x => x.TalukId, targetId), ct);

            source.IsActive = false;
            audit.Add(AuditActions.TalukMerged, "Taluk", source.Code, $"'{source.Name}' -> '{target.Name}' ({moved} addresses)");
            await db.SaveChangesAsync(ct);
            await transaction.CommitAsync(ct);
            return moved;
        });
    }

    private async Task UpdateAsync<T>(DbSet<T> set, string kind, int id, UpdateLocationRequest request,
        Func<T, string, Task<bool>> nameTakenAsync, CancellationToken ct) where T : MasterDataEntity
    {
        var entity = await set.SingleOrDefaultAsync(e => e.Id == id, ct) ?? throw new NotFoundException($"{kind} not found.");
        var changes = new List<string>();

        if (request.Name is not null)
        {
            var name = request.Name.Tidy();
            if (name.Length < 2 || name.Length > 150)
                throw new RequestValidationException([new ApiError("name", "Please enter a name of 2-150 characters.")]);
            if (name != entity.Name)
            {
                if (await nameTakenAsync(entity, name))
                    throw new ConflictException($"'{name}' already exists here. Merge instead of renaming.");
                changes.Add($"name '{entity.Name}' -> '{name}'");
                entity.Name = name;
            }
        }
        if (request.IsActive is { } active && active != entity.IsActive)
        {
            changes.Add(active ? "activated" : "deactivated");
            entity.IsActive = active;
        }

        if (changes.Count == 0) return;
        audit.Add(AuditActions.LocationUpdated, kind, entity.Code, string.Join("; ", changes));
        await db.SaveChangesAsync(ct);
    }
}
