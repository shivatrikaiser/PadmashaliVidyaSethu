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
        b.Property(e => e.PoweredBy).HasMaxLength(150);
        b.Property(e => e.SponsorLogoContentType).HasMaxLength(30).IsUnicode(false);
        b.Property(e => e.ModifiedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.ModifiedBy).HasMaxLength(ConfigurationExtensions.AuditUserLength);
        b.HasData(new AppBranding { AppBrandingId = AppBranding.SingletonId, PoweredBy = "IQ Explore" });
    }
}
