namespace PadmashaliVidyaSetu.Api.DTOs;

// ---- Member app ----

/// <summary>
/// An event as one member sees it: only the groups that fit the member's age (on <see cref="AgeAsOnDate"/>) and
/// gender, and the member's own registration, if any.
/// </summary>
public sealed record MemberEventDto(
    int EventId,
    string Code,
    string Title,
    string? Description,
    string? Venue,
    DateOnly EventDate,
    DateOnly AgeAsOnDate,
    DateOnly RegistrationOpensDate,
    DateOnly RegistrationClosesDate,
    int MaxGroupsPerMember,
    /// <summary>The member's age on <see cref="AgeAsOnDate"/>.</summary>
    int Age,
    /// <summary>Today is between the opening and closing dates: the member can register, change or cancel.</summary>
    bool IsRegistrationOpen,
    IReadOnlyList<MemberEventGroupDto> Groups,
    MemberEventRegistrationDto? Registration);

public sealed record MemberEventGroupDto(int Id, string Name, int MinAge, int MaxAge, string? Gender, bool IsFull);

/// <summary>The member's (active) registration for the event.</summary>
public sealed record MemberEventRegistrationDto(string RegistrationNumber, DateTime RegisteredDate, IReadOnlyList<int> GroupIds,
    IReadOnlyList<string> GroupNames);

public sealed record EventRegistrationRequest(IReadOnlyList<int>? GroupIds);

/// <summary>Shown on the "Registered" screen.</summary>
public sealed record EventRegistrationResultDto(
    string RegistrationNumber,
    int EventId,
    string EventTitle,
    DateOnly EventDate,
    string? Venue,
    string RegistrationId,
    string MemberName,
    IReadOnlyList<string> Groups);

// ---- Admin portal ----

public sealed record AdminEventRowDto(
    int Id,
    string Code,
    string Title,
    DateOnly EventDate,
    DateOnly RegistrationOpensDate,
    DateOnly RegistrationClosesDate,
    bool IsPublished,
    bool IsActive,
    int GroupCount,
    int RegistrationCount);

public sealed record AdminEventDto(
    int Id,
    string Code,
    string Title,
    string? Description,
    string? Venue,
    DateOnly EventDate,
    DateOnly AgeAsOnDate,
    DateOnly RegistrationOpensDate,
    DateOnly RegistrationClosesDate,
    int MaxGroupsPerMember,
    bool IsPublished,
    bool IsActive,
    int RegistrationCount,
    IReadOnlyList<AdminEventGroupDto> Groups,
    DateTime? ModifiedDate,
    string? ModifiedBy);

public sealed record AdminEventGroupDto(int Id, string Name, int MinAge, int MaxAge, int? GenderId, string? GenderName,
    int? Capacity, int RegistrationCount);

/// <summary>Adds or updates an event with its groups (the list replaces the event's groups, in this order).</summary>
public sealed record SaveEventRequest(
    string? Code,
    string? Title,
    string? Description,
    string? Venue,
    DateOnly? EventDate,
    DateOnly? AgeAsOnDate,
    DateOnly? RegistrationOpensDate,
    DateOnly? RegistrationClosesDate,
    int MaxGroupsPerMember,
    bool IsPublished,
    bool IsActive,
    IReadOnlyList<SaveEventGroupRequest>? Groups);

/// <summary><c>Id</c> null = a new group.</summary>
public sealed record SaveEventGroupRequest(int? Id, string? Name, int? MinAge, int? MaxAge, int? GenderId, int? Capacity);

public sealed record AdminEventRegistrationDto(
    string RegistrationNumber,
    string RegistrationId,
    string FullName,
    string Gender,
    int Age,
    IReadOnlyList<string> Groups,
    string Temple,
    string Mobile,
    bool IsActive,
    DateTime RegisteredDate,
    DateTime? CancelledDate);
