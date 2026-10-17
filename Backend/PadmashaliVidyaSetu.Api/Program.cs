using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.Middleware;
using Serilog;

var builder = WebApplication.CreateBuilder(args);

builder.Host.UseSerilog((context, services, logger) => logger
    .ReadFrom.Configuration(context.Configuration)
    .ReadFrom.Services(services)
    .Enrich.FromLogContext());

builder.Services
    .AddPvsOptions(builder.Configuration)
    .AddPvsData()
    .AddPvsAuthentication()
    .AddPvsServices()
    .AddPvsApi()
    .AddPvsRateLimiting();

var app = builder.Build();

if (app.Services.GetRequiredService<IOptions<DatabaseOptions>>().Value.ApplyMigrationsOnStartup)
{
    await using var scope = app.Services.CreateAsyncScope();
    var database = scope.ServiceProvider.GetRequiredService<AppDbContext>().Database;
    LocalDatabaseGuard.EnsureLocal(database.GetConnectionString()!, "Applying migrations on startup");
    await database.MigrateAsync();
}

app.UseMiddleware<ExceptionHandlingMiddleware>();
app.UseMiddleware<SecurityHeadersMiddleware>();
app.UseSerilogRequestLogging();

if (!app.Environment.IsDevelopment())
{
    app.UseHsts();
    app.UseHttpsRedirection();
}

app.UseCors();
app.UseAuthentication();
app.UseRateLimiter();
app.UseAuthorization();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi().AllowAnonymous();
}

app.MapHealthChecks("/health").AllowAnonymous();
app.MapControllers();

await app.RunAsync();

/// <summary>Exposed for WebApplicationFactory-based integration tests.</summary>
public partial class Program;
