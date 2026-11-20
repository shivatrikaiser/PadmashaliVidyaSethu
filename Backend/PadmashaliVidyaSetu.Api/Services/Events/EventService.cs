using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Events;
using PadmashaliVidyaSetu.Api.Logging;

namespace PadmashaliVidyaSetu.Api.Services.Events;

public interface IEventService
{
    Task<IReadOnlyList<MemberEventDto>> ListForMemberAsync(string registrationId, CancellationToken ct);
    Task<EventRegistrationResultDto> RegisterAsync(string registrationId, int eventId, EventRegistrationRequest request, CancellationToken ct);
    Task CancelAsync(string registrationId, int eventId, CancellationToken ct);
}

/// <summary>
/// Event registrations in the app. A member sees a published event until its registration closes (or, once
/// registered, until the event day), with only the groups that fit the member's age on the event's "age as on" date
/// and gender; events with no such group are not shown. One registration (and number) per member and event.
/// </summary>
public sealed class EventService(
    AppDbContext db,
    ICurrentUserService currentUser,
    IAuditLogger audit,
    TimeProvider clock) : IEventService
{
    public async Task<IReadOnlyList<MemberEventDto>> ListForMemberAsync(string registrationId, CancellationToken ct)
    {
        var member = await OwnMemberAsync(registrationId, ct);
        var today = clock.TodayInIndia();

        var events = await db.Events.AsNoTracking()
            .Where(e => e.IsActive && e.IsPublished && e.EventDate >= today)
            .Where(e => e.RegistrationClosesDate >= today
                        || db.EventRegistrations.Any(r => r.EventId == e.EventId && r.RegistrationId == registrationId && r.IsActive))
            .Include(e => e.Groups.Where(g => g.IsActive).OrderBy(g => g.DisplayOrder)).ThenInclude(g => g.Gender)
            .OrderBy(e => e.EventDate).ThenBy(e => e.Title)
            .AsSplitQuery()
            .ToListAsync(ct);
        if (events.Count == 0) return [];

        var eventIds = events.Select(e => e.EventId).ToList();
        var mine = await db.EventRegistrations.AsNoTracking()
            .Where(r => r.RegistrationId == registrationId && r.IsActive && eventIds.Contains(r.EventId))
            .Select(r => new { r.EventId, r.RegistrationNumber, r.RegisteredDate, GroupIds = r.Groups.Select(g => g.EventGroupId).ToList() })
            .ToListAsync(ct);
        var taken = await TakenPlacesAsync(eventIds, null, ct);

        var result = new List<MemberEventDto>();
        foreach (var e in events)
        {
            var age = AgeCalculator.AgeOn(member.DateOfBirth, e.AgeAsOnDate);
            var registration = mine.SingleOrDefault(r => r.EventId == e.EventId);
            var groups = e.Groups.Where(g => Fits(g, age, member.GenderId) || (registration?.GroupIds.Contains(g.EventGroupId) ?? false)).ToList();
            if (groups.Count == 0) continue;

            result.Add(new MemberEventDto(
                e.EventId, e.Code, e.Title, e.Description, e.Venue, e.EventDate, e.AgeAsOnDate,
                e.RegistrationOpensDate, e.RegistrationClosesDate, e.MaxGroupsPerMember, age, IsOpen(e, today),
                groups.Select(g => new MemberEventGroupDto(g.EventGroupId, g.Name, g.MinAge, g.MaxAge, g.Gender?.Name,
                    g.Capacity is { } capacity && taken.GetValueOrDefault(g.EventGroupId) >= capacity)).ToList(),
                registration is null ? null : new MemberEventRegistrationDto(registration.RegistrationNumber, registration.RegisteredDate,
                    registration.GroupIds, groups.Where(g => registration.GroupIds.Contains(g.EventGroupId)).Select(g => g.Name).ToList())));
        }
        return result;
    }

    public Task<EventRegistrationResultDto> RegisterAsync(string registrationId, int eventId, EventRegistrationRequest request,
        CancellationToken ct) =>
        db.Database.CreateExecutionStrategy().ExecuteAsync(() => RegisterCoreAsync(registrationId, eventId, request, ct));

    private async Task<EventRegistrationResultDto> RegisterCoreAsync(string registrationId, int eventId, EventRegistrationRequest request,
        CancellationToken ct)
    {
        db.ChangeTracker.Clear();
        var member = await OwnMemberAsync(registrationId, ct);
        var groupIds = (request.GroupIds ?? []).Distinct().ToList();

        await using var transaction = await db.Database.BeginTransactionAsync(ct);
        // Locks the event row until commit, so places in a group are counted one registration at a time.
        var locked = await db.Database.ExecuteSqlAsync(
            $"UPDATE dbo.PVS_Events SET LastRegistrationNumber = LastRegistrationNumber WHERE EventId = {eventId}", ct);
        var ev = locked == 0 ? null : await db.Events
            .Include(e => e.Groups.Where(g => g.IsActive))
            .SingleOrDefaultAsync(e => e.EventId == eventId && e.IsActive && e.IsPublished, ct);
        if (ev is null) throw new NotFoundException("This event is not available.");

        EnsureOpen(ev);
        if (groupIds.Count == 0)
            throw new RequestValidationException("groupIds", "Choose a group.");
        if (groupIds.Count > ev.MaxGroupsPerMember)
            throw new RequestValidationException("groupIds", ev.MaxGroupsPerMember == 1
                ? "Choose only one group."
                : $"Choose at most {ev.MaxGroupsPerMember} groups.");

        var age = AgeCalculator.AgeOn(member.DateOfBirth, ev.AgeAsOnDate);
        var registration = await db.EventRegistrations.Include(r => r.Groups)
            .SingleOrDefaultAsync(r => r.EventId == eventId && r.RegistrationId == registrationId, ct);
        var current = registration is { IsActive: true } ? registration.Groups.Select(g => g.EventGroupId).ToHashSet() : [];

        var chosen = new List<EventGroup>();
        foreach (var id in groupIds)
        {
            var group = ev.Groups.SingleOrDefault(g => g.EventGroupId == id);
            // A group the member already has stays allowed (e.g. an admin later changed its ages).
            if (group is null || (!Fits(group, age, member.GenderId) && !current.Contains(id)))
                throw new RequestValidationException("groupIds", "This group is not open to this member.");
            chosen.Add(group);
        }

        var taken = await TakenPlacesAsync([eventId], registration?.EventRegistrationId, ct);
        var full = chosen.FirstOrDefault(g => !current.Contains(g.EventGroupId) && g.Capacity is { } c && taken.GetValueOrDefault(g.EventGroupId) >= c);
        if (full is not null)
            throw new BusinessRuleException($"\"{full.Name}\" is full. Please choose another group.");

        var now = clock.GetUtcNow().UtcDateTime;
        var isNew = registration is null;
        if (registration is null)
        {
            var number = await NextNumberAsync(ev, ct);
            registration = new EventRegistration
            {
                EventId = eventId, RegistrationId = registrationId, RegistrationNumber = number, RegisteredDate = now,
            };
            db.EventRegistrations.Add(registration);
        }
        else if (!registration.IsActive)
        {
            // Registering again after cancelling: same number, new date.
            registration.IsActive = true;
            registration.CancelledDate = null;
            registration.RegisteredDate = now;
        }
        registration.AgeOnAgeAsOnDate = age;
        registration.Groups.Clear();
        foreach (var g in chosen) registration.Groups.Add(new EventRegistrationGroup { EventGroupId = g.EventGroupId });

        audit.Add(AuditActions.EventRegistered, "EventRegistration", registration.RegistrationNumber,
            $"{registrationId} {(isNew ? "registered for" : "updated")} event {ev.Code}: {string.Join(", ", chosen.Select(g => g.Name))}");
        await db.SaveChangesAsync(ct);
        await transaction.CommitAsync(ct);

        return new EventRegistrationResultDto(registration.RegistrationNumber, ev.EventId, ev.Title, ev.EventDate, ev.Venue,
            registrationId, member.FullName, chosen.Select(g => g.Name).ToList());
    }

    public async Task CancelAsync(string registrationId, int eventId, CancellationToken ct)
    {
        await OwnMemberAsync(registrationId, ct);
        var registration = await db.EventRegistrations.Include(r => r.Event)
            .SingleOrDefaultAsync(r => r.EventId == eventId && r.RegistrationId == registrationId && r.IsActive, ct)
            ?? throw new NotFoundException("This member is not registered for this event.");
        EnsureOpen(registration.Event);

        registration.IsActive = false;
        registration.CancelledDate = clock.GetUtcNow().UtcDateTime;
        audit.Add(AuditActions.EventRegistrationCancelled, "EventRegistration", registration.RegistrationNumber,
            $"{registrationId} cancelled event {registration.Event.Code}");
        await db.SaveChangesAsync(ct);
    }

    /// <summary>Age within the group's range and, when the group has one, the same gender.</summary>
    internal static bool Fits(EventGroup group, int age, int genderId) =>
        age >= group.MinAge && age <= group.MaxAge && (group.GenderId is null || group.GenderId == genderId);

    private static bool IsOpen(Event e, DateOnly today) => today >= e.RegistrationOpensDate && today <= e.RegistrationClosesDate;

    private void EnsureOpen(Event e)
    {
        var today = clock.TodayInIndia();
        if (today < e.RegistrationOpensDate)
            throw new BusinessRuleException($"Registration for this event opens on {e.RegistrationOpensDate:dd-MM-yyyy}.");
        if (today > e.RegistrationClosesDate)
            throw new BusinessRuleException("Registration for this event has closed.");
    }

    /// <summary>Active registrations per group (optionally leaving one registration out).</summary>
    private async Task<Dictionary<int, int>> TakenPlacesAsync(IReadOnlyCollection<int> eventIds, int? except, CancellationToken ct) =>
        await db.EventRegistrationGroups.AsNoTracking()
            .Where(g => eventIds.Contains(g.EventRegistration.EventId) && g.EventRegistration.IsActive
                        && g.EventRegistrationId != except)
            .GroupBy(g => g.EventGroupId)
            .Select(g => new { g.Key, Count = g.Count() })
            .ToDictionaryAsync(g => g.Key, g => g.Count, ct);

    /// <summary>Next number for the event (its row is locked by the caller's transaction): CODE-0001, CODE-0002, ...</summary>
    private async Task<string> NextNumberAsync(Event ev, CancellationToken ct)
    {
        if (ev.LastRegistrationNumber >= Event.MaxSequence)
            throw new BusinessRuleException("This event has reached the maximum number of registrations.");
        ev.LastRegistrationNumber++;
        await db.SaveChangesAsync(ct);
        return Format(ev.Code, ev.LastRegistrationNumber);
    }

    public static string Format(string eventCode, int sequence) => $"{eventCode}-{sequence:D4}";

    /// <summary>A member of the signed-in account ("not found" otherwise, so IDs cannot be probed).</summary>
    private async Task<(string FullName, DateOnly DateOfBirth, int GenderId)> OwnMemberAsync(string registrationId, CancellationToken ct)
    {
        var accountId = currentUser.RequireAccountId();
        var m = await db.Members.AsNoTracking()
            .Where(x => x.RegistrationId == registrationId && x.AccountId == accountId && x.IsActive)
            .Select(x => new { x.FullName, x.DateOfBirth, x.GenderId })
            .SingleOrDefaultAsync(ct)
            ?? throw new NotFoundException("Member not found.");
        return (m.FullName, m.DateOfBirth, m.GenderId);
    }
}
