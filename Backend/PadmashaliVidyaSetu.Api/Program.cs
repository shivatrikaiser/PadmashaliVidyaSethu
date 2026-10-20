using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.Middleware;
using PadmashaliVidyaSetu.Api.Authentication;
using Serilog;

// `dotnet run -- hash-password`: prints the hash of a password typed in (not shown), for
// Database/seed/05_SetSuperAdminPassword.TEMPLATE.sql. Nothing is stored or sent anywhere.
if (args is ["hash-password", ..])
{
    Console.Error.Write("Password: ");
    var password = ReadHidden();
    AdminPasswords.Validate(password);
    Console.WriteLine(new AdminPasswords().Hash(password));
    return;

    static string ReadHidden()
    {
        if (Console.IsInputRedirected) return Console.ReadLine() ?? string.Empty;
        var text = new System.Text.StringBuilder();
        for (var key = Console.ReadKey(intercept: true); key.Key != ConsoleKey.Enter; key = Console.ReadKey(intercept: true))
        {
            if (key.Key == ConsoleKey.Backspace) { if (text.Length > 0) text.Length--; }
            else if (!char.IsControl(key.KeyChar)) text.Append(key.KeyChar);
        }
        Console.Error.WriteLine();
        return text.ToString();
    }
}

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

// Swagger UI for testing (see SwaggerSettings). Served before authentication: the page itself is public, the API
// calls it makes still need a token.
var swaggerEnabled = SwaggerSettings.IsEnabled(app.Configuration, app.Environment);
if (swaggerEnabled)
{
    app.UseSwaggerUI(o =>
    {
        o.RoutePrefix = SwaggerSettings.UiPath.TrimStart('/');
        o.SwaggerEndpoint("/openapi/v1.json", "PVS API v1");
        o.DocumentTitle = "PVS API";
        o.EnablePersistAuthorization();
    });
}

app.UseCors();
app.UseAuthentication();
app.UseRateLimiter();
app.UseAuthorization();

if (swaggerEnabled)
{
    app.MapOpenApi().AllowAnonymous();
}

app.MapHealthChecks("/health").AllowAnonymous();
app.MapControllers();

await app.RunAsync();

/// <summary>Exposed for WebApplicationFactory-based integration tests.</summary>
public partial class Program;
