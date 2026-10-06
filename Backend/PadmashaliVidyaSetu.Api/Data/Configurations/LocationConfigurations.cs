using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Data.Seed;
using PadmashaliVidyaSetu.Api.Entities.Locations;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

public class CountryConfiguration : IEntityTypeConfiguration<Country>
{
    public void Configure(EntityTypeBuilder<Country> b)
    {
        b.ConfigureMasterData("Countries", "CountryId");
        b.HasData(SeedData.Countries);
    }
}

public class StateConfiguration : IEntityTypeConfiguration<State>
{
    public void Configure(EntityTypeBuilder<State> b)
    {
        b.ConfigureMasterData("States", "StateId", uniqueName: false);
        b.Property(e => e.PostalName).HasMaxLength(ConfigurationExtensions.NameLength);
        b.HasIndex(e => new { e.CountryId, e.Name }).IsUnique();
        b.HasOne(e => e.Country).WithMany(c => c.States).HasForeignKey(e => e.CountryId).OnDelete(DeleteBehavior.Restrict);
        b.HasData(SeedData.States);
    }
}

public class DistrictConfiguration : IEntityTypeConfiguration<District>
{
    public void Configure(EntityTypeBuilder<District> b)
    {
        b.ConfigureMasterData("Districts", "DistrictId", uniqueName: false);
        b.Property(e => e.PostalName).HasMaxLength(ConfigurationExtensions.NameLength);
        b.Property(e => e.Source).HasMaxLength(20).IsUnicode(false).IsRequired();
        b.HasIndex(e => new { e.StateId, e.Name }).IsUnique();
        b.HasOne(e => e.State).WithMany(s => s.Districts).HasForeignKey(e => e.StateId).OnDelete(DeleteBehavior.Restrict);
        b.HasData(SeedData.Districts);
    }
}

public class TalukConfiguration : IEntityTypeConfiguration<Taluk>
{
    public void Configure(EntityTypeBuilder<Taluk> b)
    {
        b.ConfigureMasterData("Taluks", "TalukId", uniqueName: false);
        b.Property(e => e.PostalName).HasMaxLength(ConfigurationExtensions.NameLength);
        b.Property(e => e.Source).HasMaxLength(20).IsUnicode(false).IsRequired();
        b.HasIndex(e => new { e.DistrictId, e.Name }).IsUnique();
        b.HasOne(e => e.District).WithMany(d => d.Taluks).HasForeignKey(e => e.DistrictId).OnDelete(DeleteBehavior.Restrict);
        b.HasData(SeedData.Taluks);
    }
}

public class CityConfiguration : IEntityTypeConfiguration<City>
{
    public void Configure(EntityTypeBuilder<City> b)
    {
        b.ConfigureMasterData("Cities", "CityId", uniqueName: false);
        b.Property(e => e.PinCode).HasMaxLength(6).IsFixedLength().IsUnicode(false).IsRequired();
        b.Property(e => e.Source).HasMaxLength(20).IsUnicode(false).IsRequired();
        b.HasIndex(e => new { e.PinCode, e.Name }).IsUnique();
        b.HasOne(e => e.District).WithMany().HasForeignKey(e => e.DistrictId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Taluk).WithMany().HasForeignKey(e => e.TalukId).OnDelete(DeleteBehavior.Restrict);
        b.ToTable(t => t.HasCheckConstraint("CK_Cities_PinCode", "[PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'"));
    }
}
