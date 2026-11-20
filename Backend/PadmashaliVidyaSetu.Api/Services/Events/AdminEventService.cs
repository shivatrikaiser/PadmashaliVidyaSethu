using System.Text;
using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Events;
using PadmashaliVidyaSetu.Api.Logging;
using PadmashaliVidyaSetu.Api.Services.Admin;

namespace PadmashaliVidyaSetu.Api.Services.Events;

public interface IAdminEventService
{
    Task<IReadOnlyList<AdminEventRowDto>> ListAsync(CancellationToken ct);
    Task<AdminEventDto> GetAsync(int id, CancellationToken ct);
    Task<AdminEventDto> SaveAsync(int? id, SaveEventRequest request, CancellationToken ct);
    Task<IReadOnlyList<AdminEventRegistrationDto>> RegistrationsAsync(int id, CancellationToken ct);
    Task<(byte[] Csv, string Code)> ExportRegistrationsCsvAsync(int id, CancellationToken ct);
}

/// <summary>Events and their age / gender groups (admin portal), and the registrations received.</summary>
public sealed class AdminEventService(AppDbContext db, IAuditLogger audit) : IAdminEventService
{
    public const int MaxGroups = 50;

    public async Task<IReadOnlyList<AdminEventRowDto>> ListAsync(CancellationToken ct) =>
        await db.Events.AsNoTracking()
            .OrderByDescending(e => e.EventDate).ThenBy(e => e.Title)
            .Select(e => new AdminEventRowDto(e.EventId, e.Code, e.Title, e.EventDate, e.RegistrationOpensDate,
                e.RegistrationClosesDate, e.IsPublished, e.IsActive, e.Groups.Count(g => g.IsActive),
                db.EventRegistrations.Count(r => r.EventId == e.EventId && r.IsActive)))
            .ToListAsync(ct);

    public async Task<AdminEventDto> GetAsync(int id, CancellationToken ct)
    {
        var e = await db.Events.AsNoTracking()
            .Include(x => x.Groups.Where(g => g.IsActive).OrderBy(g => g.DisplayOrder)).ThenInclude(g => g.Gender)
            .SingleOrDefaultAsync(x => x.EventId == id, ct)
            ?? throw new NotFoundException("This event no longer exists.");

        var perGroup = await db.EventRegistrationGroups.AsNoTracking()
            .Where(g => g.EventRegistration.EventId == id && g.EventRegistration.IsActive)
            .GroupBy(g => g.EventGroupId)
            .Select(g => new { g.Key, Count = g.Count() })
            .ToDictionaryAsync(g => g.Key, g => g.Count, ct);
        var total = await db.EventRegistrations.CountAsync(r => r.EventId == id && r.IsActive, ct);

        return new AdminEventDto(e.EventId, e.Code, e.Title, e.Description, e.Venue, e.EventDate, e.AgeAsOnDate,
            e.RegistrationOpensDate, e.RegistrationClosesDate, e.MaxGroupsPerMember, e.IsPublished, e.IsActive, total,
            e.Groups.Select(g => new AdminEventGroupDto(g.EventGroupId, g.Name, g.MinAge, g.MaxAge, g.GenderId, g.Gender?.Name,
                g.Capacity, perGroup.GetValueOrDefault(g.EventGroupId))).ToList(),
            e.ModifiedDate ?? e.CreatedDate, e.ModifiedBy ?? e.CreatedBy);
    }

    /// <summary>Adds (<paramref name="id"/> null) or updates an event; the groups in the request replace its groups.</summary>
    public async Task<AdminEventDto> SaveAsync(int? id, SaveEventRequest request, CancellationToken ct)
    {
        var errors = new List<ApiError>();
        var code = request.Code.Tidy().ToUpperInvariant();
        if (code.Length is < 2 or > Event.MaxCodeLength || code.Any(c => c is not (>= 'A' and <= 'Z' or >= '0' and <= '9')))
            errors.Add(new("code", $"Use 2 to {Event.MaxCodeLength} letters and digits, no spaces, e.g. SPORTS26."));
        var title = Text(request.Title, "title", Event.MaxTitleLength, errors);
        if (title is null) errors.Add(new("title", "Enter the event name."));
        var description = Description(request.Description, errors);
        var venue = Text(request.Venue, "venue", Event.MaxVenueLength, errors);

        if (request.EventDate is null) errors.Add(new("eventDate", "Enter the event date."));
        if (request.AgeAsOnDate is null) errors.Add(new("ageAsOnDate", "Enter the date ages are worked out on."));
        if (request.RegistrationOpensDate is null) errors.Add(new("registrationOpensDate", "Enter the date registration opens."));
        if (request.RegistrationClosesDate is null) errors.Add(new("registrationClosesDate", "Enter the date registration closes."));
        else if (request.RegistrationOpensDate > request.RegistrationClosesDate)
            errors.Add(new("registrationClosesDate", "Registration must close on or after the day it opens."));
        else if (request.RegistrationClosesDate > request.EventDate)
            errors.Add(new("registrationClosesDate", "Registration must close on or before the event date."));
        if (request.MaxGroupsPerMember is < 1 or > MaxGroups)
            errors.Add(new("maxGroupsPerMember", $"Use a number from 1 to {MaxGroups}."));

        var groups = request.Groups ?? [];
        if (groups.Count > MaxGroups) errors.Add(new("groups", $"At most {MaxGroups} groups."));
        if (request.IsPublished && groups.Count == 0) errors.Add(new("groups", "Add at least one group before publishing."));
        var genderIds = await db.Genders.Select(g => g.Id).ToListAsync(ct);
        for (var i = 0; i < groups.Count; i++)
        {
            var g = groups[i];
            var field = $"groups[{i}]";
            if (Text(g.Name, field + ".name", EventGroup.MaxNameLength, errors) is null)
                errors.Add(new(field + ".name", "Enter the group name."));
            if (g.MinAge is null or < 0 or > 120) errors.Add(new(field + ".minAge", "Enter an age from 0 to 120."));
            if (g.MaxAge is null or < 0 or > 120) errors.Add(new(field + ".maxAge", "Enter an age from 0 to 120."));
            else if (g.MinAge > g.MaxAge) errors.Add(new(field + ".maxAge", "Max age must be at least the min age."));
            if (g.GenderId is { } genderId && !genderIds.Contains(genderId)) errors.Add(new(field + ".genderId", "Choose a gender from the list."));
            if (g.Capacity is < 1 or > 100_000) errors.Add(new(field + ".capacity", "Leave empty for no limit, or enter at least 1."));
        }
        if (groups.Where(g => g.Id is not null).GroupBy(g => g.Id).Any(x => x.Count() > 1))
            errors.Add(new("groups", "A group appears twice."));
        if (errors.Count > 0) throw new RequestValidationException(errors);

        if (await db.Events.AnyAsync(e => e.Code == code && e.EventId != id, ct))
            throw new RequestValidationException("code", "Another event already uses this code.");

        Event ev;
        if (id is null)
        {
            ev = new Event();
            db.Events.Add(ev);
        }
        else
        {
            ev = await db.Events.Include(e => e.Groups).SingleOrDefaultAsync(e => e.EventId == id, ct)
                 ?? throw new NotFoundException("This event no longer exists.");
            if (ev.Code != code && ev.LastRegistrationNumber > 0)
                throw new RequestValidationException("code", "The code cannot change once members have registered (it is part of their numbers).");
        }

        ev.Code = code;
        ev.Title = title!;
        ev.Description = description;
        ev.Venue = venue;
        ev.EventDate = request.EventDate!.Value;
        ev.AgeAsOnDate = request.AgeAsOnDate!.Value;
        ev.RegistrationOpensDate = request.RegistrationOpensDate!.Value;
        ev.RegistrationClosesDate = request.RegistrationClosesDate!.Value;
        ev.MaxGroupsPerMember = request.MaxGroupsPerMember;
        ev.IsPublished = request.IsPublished;
        ev.IsActive = request.IsActive;
        await SyncGroupsAsync(ev, groups, ct);

        audit.Add(AuditActions.EventSaved, "Event", id?.ToString(),
            $"{(id is null ? "added" : "updated")} event {code} '{ev.Title}' ({groups.Count} groups, "
            + $"{(ev.IsActive ? ev.IsPublished ? "published" : "draft" : "cancelled")})");
        await db.SaveChangesAsync(ct);
        return await GetAsync(ev.EventId, ct);
    }

    /// <summary>
    /// Updates groups by id, adds new ones, removes the rest. A group with registrations is never deleted: removing it
    /// is refused while active registrations use it, otherwise it is only hidden (kept for the records).
    /// </summary>
    private async Task SyncGroupsAsync(Event ev, IReadOnlyList<SaveEventGroupRequest> groups, CancellationToken ct)
    {
        var keep = groups.Where(g => g.Id is not null).Select(g => g.Id!.Value).ToHashSet();
        foreach (var removed in ev.Groups.Where(g => g.IsActive && !keep.Contains(g.EventGroupId)).ToList())
        {
            var used = db.EventRegistrationGroups.Where(r => r.EventGroupId == removed.EventGroupId);
            if (await used.AnyAsync(r => r.EventRegistration.IsActive, ct))
                throw new BusinessRuleException($"\"{removed.Name}\" has registrations, so it cannot be removed. Change it instead.");
            if (await used.AnyAsync(ct)) removed.IsActive = false;
            else ev.Groups.Remove(removed);
        }

        for (var i = 0; i < groups.Count; i++)
        {
            var request = groups[i];
            EventGroup group;
            if (request.Id is { } groupId)
            {
                group = ev.Groups.SingleOrDefault(g => g.EventGroupId == groupId && g.IsActive)
                        ?? throw new NotFoundException("A group of this event no longer exists. Reload the page.");
            }
            else
            {
                group = new EventGroup();
                ev.Groups.Add(group);
            }
            group.Name = request.Name.Tidy();
            group.MinAge = request.MinAge!.Value;
            group.MaxAge = request.MaxAge!.Value;
            group.GenderId = request.GenderId;
            group.Capacity = request.Capacity;
            group.DisplayOrder = i;
        }
    }

    public async Task<IReadOnlyList<AdminEventRegistrationDto>> RegistrationsAsync(int id, CancellationToken ct)
    {
        if (!await db.Events.AnyAsync(e => e.EventId == id, ct)) throw new NotFoundException("This event no longer exists.");
        var rows = await db.EventRegistrations.AsNoTracking()
            .Where(r => r.EventId == id)
            .OrderBy(r => r.RegistrationNumber)
            .Select(r => new
            {
                r.RegistrationNumber, r.RegistrationId, r.Member.FullName, Gender = r.Member.Gender.Name, r.AgeOnAgeAsOnDate,
                Groups = r.Groups.OrderBy(g => g.EventGroup.DisplayOrder).Select(g => g.EventGroup.Name).ToList(),
                Temple = r.Member.Temple.Name, Mobile = r.Member.Account.MobileNumber,
                r.IsActive, r.RegisteredDate, r.CancelledDate,
            })
            .ToListAsync(ct);
        return rows.Select(r => new AdminEventRegistrationDto(r.RegistrationNumber, r.RegistrationId, r.FullName, r.Gender,
            r.AgeOnAgeAsOnDate, r.Groups, r.Temple, r.Mobile, r.IsActive, r.RegisteredDate, r.CancelledDate)).ToList();
    }

    public async Task<(byte[] Csv, string Code)> ExportRegistrationsCsvAsync(int id, CancellationToken ct)
    {
        var code = await db.Events.Where(e => e.EventId == id).Select(e => e.Code).SingleOrDefaultAsync(ct)
                   ?? throw new NotFoundException("This event no longer exists.");
        var rows = await RegistrationsAsync(id, ct);

        var csv = new StringBuilder();
        csv.AppendLine(string.Join(',', "Event Registration No", "Member Registration ID", "Full Name", "Gender", "Age",
            "Groups", "Temple", "Mobile", "Status", "Registered (UTC)", "Cancelled (UTC)"));
        foreach (var r in rows)
        {
            csv.AppendLine(string.Join(',', new object?[]
            {
                r.RegistrationNumber, r.RegistrationId, r.FullName, r.Gender, r.Age, string.Join("; ", r.Groups), r.Temple,
                r.Mobile, r.IsActive ? "Registered" : "Cancelled", r.RegisteredDate.ToString("yyyy-MM-dd HH:mm"),
                r.CancelledDate?.ToString("yyyy-MM-dd HH:mm"),
            }.Select(AdminMemberService.CsvField)));
        }

        audit.Add(AuditActions.EventRegistrationsExported, "Event", id.ToString(), $"{code}: {rows.Count} rows");
        await db.SaveChangesAsync(ct);
        // UTF-8 with BOM so Excel shows Kannada names correctly.
        return ([.. Encoding.UTF8.GetPreamble(), .. Encoding.UTF8.GetBytes(csv.ToString())], code);
    }

    private static string? Text(string? value, string field, int max, List<ApiError> errors)
    {
        var text = value.Tidy();
        if (text.Length > max) errors.Add(new(field, $"At most {max} characters."));
        return text.Length == 0 ? null : text;
    }

    /// <summary>Lines kept (each tidied); more than one blank line in a row becomes one.</summary>
    private static string? Description(string? value, List<ApiError> errors)
    {
        var lines = (value ?? string.Empty).Replace("\r\n", "\n").Split('\n').Select(l => l.Tidy()).ToList();
        var text = string.Join('\n', lines.Where((l, i) => l.Length > 0 || (i > 0 && lines[i - 1].Length > 0))).Trim();
        if (text.Length > Event.MaxDescriptionLength)
            errors.Add(new("description", $"At most {Event.MaxDescriptionLength} characters."));
        return text.Length == 0 ? null : text;
    }
}
