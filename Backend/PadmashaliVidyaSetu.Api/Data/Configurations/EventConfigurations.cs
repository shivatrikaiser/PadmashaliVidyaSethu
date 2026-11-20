using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Entities.Events;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

public class EventConfiguration : IEntityTypeConfiguration<Event>
{
    public void Configure(EntityTypeBuilder<Event> b)
    {
        b.ToTable("Events", t =>
        {
            t.HasCheckConstraint("CK_Events_Code", "LEN([Code]) >= 2 AND [Code] NOT LIKE '%[^A-Z0-9]%'");
            t.HasCheckConstraint("CK_Events_RegistrationDates", "[RegistrationOpensDate] <= [RegistrationClosesDate]");
            t.HasCheckConstraint("CK_Events_MaxGroupsPerMember", "[MaxGroupsPerMember] BETWEEN 1 AND 50");
            t.HasCheckConstraint("CK_Events_LastRegistrationNumber", $"[LastRegistrationNumber] BETWEEN 0 AND {Event.MaxSequence}");
        });
        b.HasKey(e => e.EventId);
        b.Property(e => e.Code).HasMaxLength(Event.MaxCodeLength).IsUnicode(false).IsRequired();
        b.Property(e => e.Title).HasMaxLength(Event.MaxTitleLength).IsRequired();
        b.Property(e => e.Description).HasMaxLength(Event.MaxDescriptionLength);
        b.Property(e => e.Venue).HasMaxLength(Event.MaxVenueLength);
        b.Property(e => e.EventDate).HasColumnType("date");
        b.Property(e => e.AgeAsOnDate).HasColumnType("date");
        b.Property(e => e.RegistrationOpensDate).HasColumnType("date");
        b.Property(e => e.RegistrationClosesDate).HasColumnType("date");
        b.ConfigureAudit();
        b.HasIndex(e => e.Code).IsUnique();
        b.HasIndex(e => new { e.IsActive, e.IsPublished, e.RegistrationClosesDate });
    }
}

public class EventGroupConfiguration : IEntityTypeConfiguration<EventGroup>
{
    public void Configure(EntityTypeBuilder<EventGroup> b)
    {
        b.ToTable("EventGroups", t =>
        {
            t.HasCheckConstraint("CK_EventGroups_Ages", "[MinAge] >= 0 AND [MaxAge] <= 120 AND [MinAge] <= [MaxAge]");
            t.HasCheckConstraint("CK_EventGroups_Capacity", "[Capacity] IS NULL OR [Capacity] >= 1");
        });
        b.HasKey(e => e.EventGroupId);
        b.Property(e => e.Name).HasMaxLength(EventGroup.MaxNameLength).IsRequired();
        b.ConfigureAudit();
        b.HasIndex(e => new { e.EventId, e.DisplayOrder });
        b.HasOne(e => e.Event).WithMany(e => e.Groups).HasForeignKey(e => e.EventId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(e => e.Gender).WithMany().HasForeignKey(e => e.GenderId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class EventRegistrationConfiguration : IEntityTypeConfiguration<EventRegistration>
{
    public void Configure(EntityTypeBuilder<EventRegistration> b)
    {
        b.ToTable("EventRegistrations");
        b.HasKey(e => e.EventRegistrationId);
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);
        b.Property(e => e.RegistrationNumber).HasMaxLength(EventRegistration.NumberLength).IsUnicode(false).IsRequired();
        b.Property(e => e.RegisteredDate).HasColumnType("datetime2(3)");
        b.Property(e => e.CancelledDate).HasColumnType("datetime2(3)");
        b.ConfigureAudit();
        b.HasIndex(e => new { e.EventId, e.RegistrationId }).IsUnique();
        b.HasIndex(e => e.RegistrationNumber).IsUnique();
        b.HasIndex(e => e.RegistrationId);
        b.HasOne(e => e.Event).WithMany().HasForeignKey(e => e.EventId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Member).WithMany().HasForeignKey(e => e.RegistrationId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class EventRegistrationGroupConfiguration : IEntityTypeConfiguration<EventRegistrationGroup>
{
    public void Configure(EntityTypeBuilder<EventRegistrationGroup> b)
    {
        b.ToTable("EventRegistrationGroups");
        b.HasKey(e => new { e.EventRegistrationId, e.EventGroupId });
        b.HasIndex(e => e.EventGroupId);
        b.HasOne(e => e.EventRegistration).WithMany(r => r.Groups).HasForeignKey(e => e.EventRegistrationId)
            .OnDelete(DeleteBehavior.Cascade);
        // Groups that have registrations cannot be deleted (the admin service checks first and says so).
        b.HasOne(e => e.EventGroup).WithMany().HasForeignKey(e => e.EventGroupId).OnDelete(DeleteBehavior.Restrict);
    }
}
