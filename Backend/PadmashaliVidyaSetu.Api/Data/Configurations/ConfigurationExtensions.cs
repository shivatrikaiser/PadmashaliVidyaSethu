using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Entities.Common;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

internal static class ConfigurationExtensions
{
    public const int NameLength = 150;
    public const int CodeLength = 60;
    public const int AuditUserLength = 100;
    /// <summary>Free text entered when "Other" is chosen from a list.</summary>
    public const int OtherTextLength = 150;

    public static void ConfigureAudit<T>(this EntityTypeBuilder<T> b) where T : AuditableEntity
    {
        b.Property(e => e.CreatedDate).HasColumnType("datetime2(3)").HasDefaultValueSql("SYSUTCDATETIME()");
        b.Property(e => e.ModifiedDate).HasColumnType("datetime2(3)");
        b.Property(e => e.CreatedBy).HasMaxLength(AuditUserLength);
        b.Property(e => e.ModifiedBy).HasMaxLength(AuditUserLength);
        b.Property(e => e.IsActive).HasDefaultValue(true);
    }

    /// <summary>
    /// Standard mapping for lookup tables: <c>{Entity}Id</c> PK, unique Code, optional unique Name,
    /// and an index supporting the usual "active rows ordered for a dropdown" query.
    /// </summary>
    public static void ConfigureMasterData<T>(
        this EntityTypeBuilder<T> b, string table, string idColumn, bool uniqueName = true) where T : MasterDataEntity
    {
        b.ToTable(table);
        b.HasKey(e => e.Id);
        b.Property(e => e.Id).HasColumnName(idColumn);
        b.Property(e => e.Name).HasMaxLength(NameLength).IsRequired();
        b.Property(e => e.Code).HasMaxLength(CodeLength).IsUnicode(false).IsRequired();
        b.HasIndex(e => e.Code).IsUnique();
        if (uniqueName)
        {
            b.HasIndex(e => e.Name).IsUnique();
        }
        b.HasIndex(e => new { e.IsActive, e.DisplayOrder });
        b.ConfigureAudit();
    }
}
