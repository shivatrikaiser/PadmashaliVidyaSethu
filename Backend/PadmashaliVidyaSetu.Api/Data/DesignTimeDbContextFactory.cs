using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Design;
using PadmashaliVidyaSetu.Api.Authentication;

namespace PadmashaliVidyaSetu.Api.Data;

/// <summary>
/// Used only by <c>dotnet ef</c> (migrations / scripts). Reads the connection string from the
/// <c>PVS_DESIGN_CONNECTION</c> environment variable, falling back to the local development database.
/// </summary>
public sealed class DesignTimeDbContextFactory : IDesignTimeDbContextFactory<AppDbContext>
{
    private const string LocalDevelopment =
        "Server=(localdb)\\MSSQLLocalDB;Database=PadmashaliVidyaSetu;Trusted_Connection=True;TrustServerCertificate=True";

    public AppDbContext CreateDbContext(string[] args)
    {
        var connection = Environment.GetEnvironmentVariable("PVS_DESIGN_CONNECTION") ?? LocalDevelopment;
        var options = new DbContextOptionsBuilder<AppDbContext>().UsePvsSqlServer(connection).Options;
        return new AppDbContext(options, new SystemCurrentUserService(), TimeProvider.System);
    }
}
