using Microsoft.Data.SqlClient;

namespace PadmashaliVidyaSetu.Api.Data;

/// <summary>
/// Schema changes are applied automatically (API startup in Development, <c>dotnet ef database update</c>) only to a
/// SQL Server on this machine. Live / shared databases are changed only by running the reviewed scripts in
/// <c>Database/</c> by hand.
/// </summary>
public static class LocalDatabaseGuard
{
    private static readonly string[] LocalHosts = ["(localdb)", ".", "(local)", "localhost", "127.0.0.1", "::1"];

    public static bool IsLocal(string connectionString)
    {
        var dataSource = new SqlConnectionStringBuilder(connectionString).DataSource.Trim();
        if (dataSource.StartsWith("tcp:", StringComparison.OrdinalIgnoreCase)) dataSource = dataSource[4..];
        var host = dataSource.Split(',')[0].Split('\\')[0].Trim();
        return LocalHosts.Contains(host, StringComparer.OrdinalIgnoreCase)
            || host.Equals(Environment.MachineName, StringComparison.OrdinalIgnoreCase);
    }

    /// <summary>Throws unless the connection string points to a local SQL Server.</summary>
    public static void EnsureLocal(string connectionString, string action)
    {
        if (IsLocal(connectionString)) return;
        var server = new SqlConnectionStringBuilder(connectionString).DataSource;
        throw new InvalidOperationException(
            $"{action} is only allowed on a local SQL Server, not on '{server}'. Live databases are changed only with " +
            "the scripts in Database/ (e.g. Database/deploy/PVS_Deploy_SharedDatabase.sql). " +
            "To run the API against such a database, set Database:ApplyMigrationsOnStartup to false.");
    }
}
