using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Entities.Settings;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

public class AppBrandingConfiguration : IEntityTypeConfiguration<AppBranding>
{
    public void Configure(EntityTypeBuilder<AppBranding> b)
    {
        b.ToTable("AppBranding", t => t.HasCheckConstraint("CK_AppBranding_Singleton", "[AppBrandingId] = 1"));
        b.HasKey(e => e.AppBrandingId);
        b.Property(e => e.AppBrandingId).ValueGeneratedNever();
        b.Property(e => e.SponsorName).HasMaxLength(150);
        b.Property(e => e.SponsorOrganisation).HasMaxLength(150);
        b.Property(e => e.SponsorAddress).HasMaxLength(300);
        b.Property(e => e.PoweredBy).HasMaxLength(150);
        b.Property(e => e.SponsorLogoContentType).HasMaxLength(30).IsUnicode(false);
        b.Property(e => e.ModifiedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.ModifiedBy).HasMaxLength(ConfigurationExtensions.AuditUserLength);
        b.HasData(new AppBranding { AppBrandingId = AppBranding.SingletonId, PoweredBy = "IQ Explore" });
    }
}

public class AppVersionConfiguration : IEntityTypeConfiguration<AppVersion>
{
    public void Configure(EntityTypeBuilder<AppVersion> b)
    {
        b.ToTable("AppVersions", t =>
        {
            t.HasCheckConstraint("CK_AppVersions_Platform", "[Platform] IN ('android', 'ios')");
            // major.minor.patch, digits only (compared numerically by the app).
            t.HasCheckConstraint("CK_AppVersions_LatestVersion",
                "[LatestVersion] LIKE '[0-9]%.[0-9]%.[0-9]%' AND [LatestVersion] NOT LIKE '%[^0-9.]%'");
        });
        b.HasKey(e => e.Platform);
        b.Property(e => e.Platform).HasMaxLength(20).IsUnicode(false);
        b.Property(e => e.LatestVersion).HasMaxLength(20).IsUnicode(false);
        b.Property(e => e.StoreUrl).HasMaxLength(500);
        b.Property(e => e.ModifiedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.ModifiedBy).HasMaxLength(ConfigurationExtensions.AuditUserLength);
        b.HasData(
            new AppVersion
            {
                Platform = AppVersion.Android, LatestVersion = "1.0.0", IsMandatory = true,
                StoreUrl = "https://play.google.com/store/apps/details?id=org.padmashalividyasetu.padmashali_vidya_setu",
            },
            new AppVersion { Platform = AppVersion.Ios, LatestVersion = "1.0.0", IsMandatory = true });
    }
}

public class PushNotificationConfiguration : IEntityTypeConfiguration<PushNotification>
{
    public void Configure(EntityTypeBuilder<PushNotification> b)
    {
        b.ToTable("PushNotifications");
        b.HasKey(e => e.PushNotificationId);
        b.Property(e => e.Title).HasMaxLength(PushNotification.MaxTitleLength).IsRequired();
        b.Property(e => e.Body).HasMaxLength(PushNotification.MaxBodyLength).IsRequired();
        b.Property(e => e.Topic).HasMaxLength(100).IsUnicode(false).IsRequired();
        b.Property(e => e.FcmMessageId).HasMaxLength(200).IsUnicode(false);
        b.Property(e => e.SentDate).HasColumnType("datetime2(3)");
        b.Property(e => e.SentBy).HasMaxLength(ConfigurationExtensions.AuditUserLength);
        b.HasIndex(e => e.SentDate);
    }
}
