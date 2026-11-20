using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Entities.Members;

namespace PadmashaliVidyaSetu.Api.Entities.Events;

/// <summary>
/// An event the organisation takes registrations for in the app (sports, drawing or quiz competition, ...).
/// Members see a published event while its registration is open, with the groups that fit their age on
/// <see cref="AgeAsOnDate"/> and their gender. <see cref="IsActive"/> false = cancelled / hidden.
/// </summary>
public class Event : AuditableEntity
{
    public const int MaxCodeLength = 12;
    public const int MaxTitleLength = 150;
    public const int MaxDescriptionLength = 2000;
    public const int MaxVenueLength = 300;
    public const int MaxSequence = 9999;

    public int EventId { get; set; }

    /// <summary>Short upper-case code, e.g. SPORTS26; the start of every registration number (SPORTS26-0001).</summary>
    public string Code { get; set; } = string.Empty;

    public string Title { get; set; } = string.Empty;
    public string? Description { get; set; }
    public string? Venue { get; set; }

    public DateOnly EventDate { get; set; }

    /// <summary>Members' ages for the groups are worked out on this date (e.g. "age as on 1 June 2026").</summary>
    public DateOnly AgeAsOnDate { get; set; }

    /// <summary>First and last day (India time, inclusive) members can register, change or cancel.</summary>
    public DateOnly RegistrationOpensDate { get; set; }
    public DateOnly RegistrationClosesDate { get; set; }

    /// <summary>How many of the event's groups one member may join (at least 1).</summary>
    public int MaxGroupsPerMember { get; set; } = 1;

    /// <summary>Shown in the app only when published (drafts are visible on the admin portal only).</summary>
    public bool IsPublished { get; set; }

    /// <summary>Last registration number given for this event (allocated atomically).</summary>
    public int LastRegistrationNumber { get; set; }

    public ICollection<EventGroup> Groups { get; set; } = [];
}

/// <summary>An age (and optionally gender) group of an event, e.g. "Boys Under 12": ages 9-11, male.</summary>
public class EventGroup : AuditableEntity
{
    public const int MaxNameLength = 100;

    public int EventGroupId { get; set; }

    public int EventId { get; set; }
    public Event Event { get; set; } = null!;

    public string Name { get; set; } = string.Empty;

    /// <summary>Inclusive age range on the event's "age as on" date.</summary>
    public int MinAge { get; set; }
    public int MaxAge { get; set; }

    /// <summary>Null = open to everyone.</summary>
    public int? GenderId { get; set; }
    public Gender? Gender { get; set; }

    /// <summary>Most members the group takes; null = no limit.</summary>
    public int? Capacity { get; set; }

    public int DisplayOrder { get; set; }
}

/// <summary>
/// A member's registration for an event: one per member and event, with the groups chosen. Cancelling keeps the row
/// (<see cref="AuditableEntity.IsActive"/> false) and its number; registering again re-activates it.
/// </summary>
public class EventRegistration : AuditableEntity
{
    public const int NumberLength = Event.MaxCodeLength + 5;

    public int EventRegistrationId { get; set; }

    public int EventId { get; set; }
    public Event Event { get; set; } = null!;

    public string RegistrationId { get; set; } = string.Empty;
    public Member Member { get; set; } = null!;

    /// <summary>E.g. SPORTS26-0001, shown to the member.</summary>
    public string RegistrationNumber { get; set; } = string.Empty;

    /// <summary>The member's age on the event's "age as on" date when they registered.</summary>
    public int AgeOnAgeAsOnDate { get; set; }

    public DateTime RegisteredDate { get; set; }
    public DateTime? CancelledDate { get; set; }

    public ICollection<EventRegistrationGroup> Groups { get; set; } = [];
}

public class EventRegistrationGroup
{
    public int EventRegistrationId { get; set; }
    public EventRegistration EventRegistration { get; set; } = null!;

    public int EventGroupId { get; set; }
    public EventGroup EventGroup { get; set; } = null!;
}
