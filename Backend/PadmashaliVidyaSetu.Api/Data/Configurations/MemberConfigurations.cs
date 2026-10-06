using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Data.Seed;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Members;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

public class MemberConfiguration : IEntityTypeConfiguration<Member>
{
    public void Configure(EntityTypeBuilder<Member> b)
    {
        b.ToTable("Members", t =>
        {
            t.HasCheckConstraint("CK_Members_RegistrationId",
                "[RegistrationId] LIKE 'PVS-[0-9][0-9]-[0-9][0-9][0-9][0-9]'");
            // Class Studying (students) and Highest Education (working / unemployed) are mutually exclusive.
            t.HasCheckConstraint("CK_Members_ClassOrHighestEducation",
                "[ClassId] IS NULL OR [HighestEducationLevelId] IS NULL");
        });

        b.HasKey(e => e.RegistrationId);
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);

        b.Property(e => e.FullName).HasMaxLength(150).IsRequired();
        b.Property(e => e.FatherName).HasMaxLength(150).IsRequired();
        b.Property(e => e.MotherName).HasMaxLength(150).IsRequired();
        b.Property(e => e.DateOfBirth).HasColumnType("date");
        b.Property(e => e.RegistrationCompletedDate).HasColumnType("datetime2(3)");
        b.ConfigureAudit();

        b.HasOne(e => e.Account).WithMany().HasForeignKey(e => e.AccountId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Gender).WithMany().HasForeignKey(e => e.GenderId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Temple).WithMany().HasForeignKey(e => e.TempleId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.MemberStatus).WithMany().HasForeignKey(e => e.MemberStatusId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Class).WithMany().HasForeignKey(e => e.ClassId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.HighestEducationLevel).WithMany().HasForeignKey(e => e.HighestEducationLevelId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Organisation).WithMany().HasForeignKey(e => e.OrganisationId).OnDelete(DeleteBehavior.Restrict);

        // Reporting / filtering indexes (admin segments by temple, status, class, organisation, age).
        b.HasIndex(e => e.AccountId);
        b.HasIndex(e => e.TempleId);
        b.HasIndex(e => new { e.MemberStatusId, e.ClassId });
        b.HasIndex(e => e.OrganisationId);
        b.HasIndex(e => e.DateOfBirth);
    }
}

public class MemberAddressConfiguration : IEntityTypeConfiguration<MemberAddress>
{
    public void Configure(EntityTypeBuilder<MemberAddress> b)
    {
        b.ToTable("MemberAddresses", t =>
        {
            t.HasCheckConstraint("CK_MemberAddresses_AddressType",
                $"[AddressType] IN ('{AddressTypes.Permanent}', '{AddressTypes.Current}')");
            t.HasCheckConstraint("CK_MemberAddresses_PinCode", "[PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'");
        });
        b.HasKey(e => e.MemberAddressId);
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);
        b.Property(e => e.AddressType).HasMaxLength(10).IsUnicode(false).IsRequired();
        b.Property(e => e.AddressLine1).HasMaxLength(200).IsRequired();
        b.Property(e => e.AddressLine2).HasMaxLength(200);
        b.Property(e => e.PinCode).HasMaxLength(6).IsFixedLength().IsUnicode(false).IsRequired();
        b.Property(e => e.CityVillageName).HasMaxLength(150).IsRequired();
        b.ConfigureAudit();

        b.HasIndex(e => new { e.RegistrationId, e.AddressType }).IsUnique();
        b.HasIndex(e => new { e.DistrictId, e.TalukId });
        b.HasIndex(e => e.PinCode);

        b.HasOne(e => e.Member).WithMany(m => m.Addresses).HasForeignKey(e => e.RegistrationId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(e => e.City).WithMany().HasForeignKey(e => e.CityId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Taluk).WithMany().HasForeignKey(e => e.TalukId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.District).WithMany().HasForeignKey(e => e.DistrictId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.State).WithMany().HasForeignKey(e => e.StateId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Country).WithMany().HasForeignKey(e => e.CountryId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class MemberDisabilityConfiguration : IEntityTypeConfiguration<MemberDisability>
{
    public void Configure(EntityTypeBuilder<MemberDisability> b)
    {
        b.ToTable("MemberDisabilities");
        b.HasKey(e => new { e.RegistrationId, e.DisabilityTypeId });
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);
        b.Property(e => e.CreatedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.CreatedBy).HasMaxLength(ConfigurationExtensions.AuditUserLength);
        b.HasOne(e => e.Member).WithMany(m => m.Disabilities).HasForeignKey(e => e.RegistrationId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(e => e.DisabilityType).WithMany().HasForeignKey(e => e.DisabilityTypeId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class TempleRegistrationSequenceConfiguration : IEntityTypeConfiguration<TempleRegistrationSequence>
{
    public void Configure(EntityTypeBuilder<TempleRegistrationSequence> b)
    {
        b.ToTable("TempleRegistrationSequences", t =>
            t.HasCheckConstraint("CK_TempleRegistrationSequences_Range", "[LastSequenceNumber] BETWEEN 0 AND 9999"));
        b.HasKey(e => e.TempleId);
        b.Property(e => e.TempleId).ValueGeneratedNever();
        b.HasOne(e => e.Temple).WithOne().HasForeignKey<TempleRegistrationSequence>(e => e.TempleId).OnDelete(DeleteBehavior.Restrict);
        b.HasData(SeedData.TempleSequences);
    }
}

public class ConsentRecordConfiguration : IEntityTypeConfiguration<ConsentRecord>
{
    public void Configure(EntityTypeBuilder<ConsentRecord> b)
    {
        b.ToTable("ConsentRecords");
        b.HasKey(e => e.ConsentRecordId);
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);
        b.Property(e => e.ConsentType).HasMaxLength(40).IsUnicode(false).IsRequired();
        b.Property(e => e.PolicyVersion).HasMaxLength(20).IsUnicode(false).IsRequired();
        b.Property(e => e.IpAddress).HasMaxLength(45).IsUnicode(false);
        b.Property(e => e.RecordedDate).HasColumnType("datetime2(3)");
        b.HasIndex(e => new { e.AccountId, e.ConsentType });
        b.HasIndex(e => e.RegistrationId);
        b.HasOne<Entities.Accounts.Account>().WithMany().HasForeignKey(e => e.AccountId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne<Member>().WithMany().HasForeignKey(e => e.RegistrationId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class AuditLogConfiguration : IEntityTypeConfiguration<AuditLog>
{
    public void Configure(EntityTypeBuilder<AuditLog> b)
    {
        b.ToTable("AuditLogs");
        b.HasKey(e => e.AuditLogId);
        b.Property(e => e.Action).HasMaxLength(100).IsUnicode(false).IsRequired();
        b.Property(e => e.EntityName).HasMaxLength(100).IsUnicode(false);
        b.Property(e => e.EntityKey).HasMaxLength(50);
        b.Property(e => e.Details).HasMaxLength(1000);
        b.Property(e => e.IpAddress).HasMaxLength(45).IsUnicode(false);
        b.Property(e => e.CreatedDate).HasColumnType("datetime2(3)");
        b.HasIndex(e => e.CreatedDate);
        b.HasIndex(e => new { e.AccountId, e.CreatedDate });
        // No FK to Accounts: audit rows must survive account deletion requests.
    }
}
