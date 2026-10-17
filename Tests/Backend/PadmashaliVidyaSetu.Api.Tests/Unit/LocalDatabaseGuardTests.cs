using PadmashaliVidyaSetu.Api.Data;

namespace PadmashaliVidyaSetu.Api.Tests.Unit;

public sealed class LocalDatabaseGuardTests
{
    [Theory]
    [InlineData(@"Server=(localdb)\MSSQLLocalDB;Database=PadmashaliVidyaSetu;Trusted_Connection=True")]
    [InlineData("Server=localhost;Database=PVS;Trusted_Connection=True")]
    [InlineData(@"Data Source=.\SQLEXPRESS;Initial Catalog=PVS;Integrated Security=True")]
    [InlineData("Server=tcp:127.0.0.1,1433;Database=PVS;User ID=sa;Password=x")]
    [InlineData("Server=(local);Database=PVS;Trusted_Connection=True")]
    public void LocalServers_AreAllowed(string connectionString) =>
        Assert.True(LocalDatabaseGuard.IsLocal(connectionString));

    [Theory]
    [InlineData("Server=tcp:iqexploresql.database.windows.net,1433;Initial Catalog=IQExploreDB_live;User ID=u;Password=p")]
    [InlineData("Data Source=iqexploresql.database.windows.net;Initial Catalog=IQExploreDB_live;User ID=u;Password=p")]
    [InlineData(@"Server=10.0.0.5\SQL2022;Database=PVS;User ID=u;Password=p")]
    public void RemoteServers_AreRefused(string connectionString)
    {
        Assert.False(LocalDatabaseGuard.IsLocal(connectionString));
        var error = Assert.Throws<InvalidOperationException>(() => LocalDatabaseGuard.EnsureLocal(connectionString, "Applying migrations"));
        Assert.Contains("ApplyMigrationsOnStartup", error.Message);
    }
}
