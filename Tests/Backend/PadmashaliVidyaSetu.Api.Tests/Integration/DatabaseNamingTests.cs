using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.Tests.Infrastructure;

namespace PadmashaliVidyaSetu.Api.Tests.Integration;

[Collection(ApiCollection.Name)]
public sealed class DatabaseNamingTests(PvsApiFactory factory)
{
    [Fact]
    public async Task EverySqlObject_StartsWithPvsPrefix()
    {
        // Tables, keys, foreign keys, check and default constraints, plus every named index of the migrated database.
        var names = await factory.WithDbAsync(db => db.Database.SqlQuery<string>($"""
            SELECT o.name AS [Value] FROM sys.objects o WHERE o.is_ms_shipped = 0
            UNION
            SELECT i.name FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id
            WHERE i.name IS NOT NULL AND t.is_ms_shipped = 0
            """).ToListAsync());

        Assert.Contains(SqlObjectNaming.MigrationsHistoryTable, names);
        Assert.Contains("PVS_TempleRegistrationSequences", names);
        Assert.DoesNotContain(names, n => !n.StartsWith(SqlObjectNaming.Prefix, StringComparison.Ordinal));
    }
}
