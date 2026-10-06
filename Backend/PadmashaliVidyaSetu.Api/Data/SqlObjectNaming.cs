using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Infrastructure;
using Microsoft.EntityFrameworkCore.Metadata;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using Microsoft.EntityFrameworkCore.Migrations;
using Microsoft.EntityFrameworkCore.SqlServer.Migrations.Internal;

namespace PadmashaliVidyaSetu.Api.Data;

/// <summary>
/// Every SQL object the application creates starts with <see cref="Prefix"/>. Entity configurations use plain names
/// (<c>ToTable("Accounts")</c>, <c>"CK_Accounts_MobileNumber"</c>); <see cref="ApplyPvsNaming"/> turns them into:
/// <list type="bullet">
/// <item>tables <c>PVS_Accounts</c> (and the migrations history table <c>PVS_EFMigrationsHistory</c>)</item>
/// <item>primary / alternate keys <c>PVS_PK_Accounts</c>, <c>PVS_AK_Accounts_Column</c></item>
/// <item>foreign keys <c>PVS_FK_AccountRoles_Accounts_AccountId</c></item>
/// <item>indexes <c>PVS_IX_AccountRoles_RoleId</c></item>
/// <item>check constraints <c>PVS_CK_Accounts_MobileNumber</c></item>
/// <item>default constraints <c>PVS_DF_Accounts_CreatedDate</c></item>
/// </list>
/// </summary>
public static class SqlObjectNaming
{
    public const string Prefix = "PVS_";
    public const string MigrationsHistoryTable = Prefix + "EFMigrationsHistory";

    /// <summary>SQL Server, with the PVS_ migrations history table. Used by the API and by <c>dotnet ef</c>.</summary>
    public static TBuilder UsePvsSqlServer<TBuilder>(
        this TBuilder options, string connectionString, Action<SqlServerDbContextOptionsBuilder>? configure = null)
        where TBuilder : DbContextOptionsBuilder
    {
        options.UseSqlServer(connectionString, sql =>
        {
            sql.MigrationsHistoryTable(MigrationsHistoryTable);
            configure?.Invoke(sql);
        });
        options.ReplaceService<IHistoryRepository, PvsHistoryRepository>();
        return options;
    }

    /// <summary>Call last in <c>OnModelCreating</c>, after all entity configurations.</summary>
    public static void ApplyPvsNaming(this ModelBuilder modelBuilder)
    {
        foreach (var entity in modelBuilder.Model.GetEntityTypes())
        {
            var table = entity.GetTableName();
            if (table is null)
                continue;

            var name = Unprefixed(table);
            entity.SetTableName(Prefix + name);

            foreach (var key in entity.GetDeclaredKeys())
                key.SetName(key.IsPrimaryKey()
                    ? $"{Prefix}PK_{name}"
                    : $"{Prefix}AK_{name}_{Columns(key.Properties)}");

            foreach (var fk in entity.GetDeclaredForeignKeys())
                fk.SetConstraintName(
                    $"{Prefix}FK_{name}_{Unprefixed(fk.PrincipalEntityType.GetTableName()!)}_{Columns(fk.Properties)}");

            foreach (var index in entity.GetDeclaredIndexes())
                index.SetDatabaseName($"{Prefix}IX_{name}_{Columns(index.Properties)}");

            foreach (var check in entity.GetDeclaredCheckConstraints())
                check.Name = Prefixed(check.Name ?? check.ModelName);

            foreach (var property in entity.GetDeclaredProperties())
                if (property.FindAnnotation(RelationalAnnotationNames.DefaultValue) is not null
                    || property.GetDefaultValueSql() is not null)
                    property.SetDefaultConstraintName($"{Prefix}DF_{name}_{property.GetColumnName()}");
        }
    }

    private static string Prefixed(string name) => name.StartsWith(Prefix, StringComparison.Ordinal) ? name : Prefix + name;

    private static string Unprefixed(string name) => name.StartsWith(Prefix, StringComparison.Ordinal) ? name[Prefix.Length..] : name;

    private static string Columns(IEnumerable<IReadOnlyProperty> properties) =>
        string.Join("_", properties.Select(p => p.GetColumnName()));
}

/// <summary>Names the migrations history table's primary key <c>PVS_PK_EFMigrationsHistory</c>.</summary>
#pragma warning disable EF1001 // SqlServerHistoryRepository is the documented extension point for the history table.
internal sealed class PvsHistoryRepository(HistoryRepositoryDependencies dependencies) : SqlServerHistoryRepository(dependencies)
{
    protected override void ConfigureTable(EntityTypeBuilder<HistoryRow> history)
    {
        base.ConfigureTable(history);
        history.HasKey(h => h.MigrationId).HasName(SqlObjectNaming.Prefix + "PK_EFMigrationsHistory");
    }
}
#pragma warning restore EF1001
