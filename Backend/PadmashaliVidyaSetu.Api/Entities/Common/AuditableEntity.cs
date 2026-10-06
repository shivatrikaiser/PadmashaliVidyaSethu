namespace PadmashaliVidyaSetu.Api.Entities.Common;

/// <summary>
/// Standard audit columns carried by every business table.
/// Values are populated automatically in <c>AppDbContext.SaveChangesAsync</c>.
/// </summary>
public abstract class AuditableEntity
{
    public DateTime CreatedDate { get; set; }
    public DateTime? ModifiedDate { get; set; }
    public string? CreatedBy { get; set; }
    public string? ModifiedBy { get; set; }
    public bool IsActive { get; set; } = true;
}

/// <summary>
/// Shape shared by configurable lookup tables (temples, organisations, classes, ...).
/// The <see cref="Id"/> property is mapped to a table-specific column name such as <c>TempleId</c>.
/// <see cref="Code"/> is a stable identifier that application logic may rely on;
/// <see cref="Name"/> is display text administrators may edit freely.
/// </summary>
public abstract class MasterDataEntity : AuditableEntity
{
    public int Id { get; set; }
    public string Name { get; set; } = string.Empty;
    public string Code { get; set; } = string.Empty;
    public int DisplayOrder { get; set; }
}
