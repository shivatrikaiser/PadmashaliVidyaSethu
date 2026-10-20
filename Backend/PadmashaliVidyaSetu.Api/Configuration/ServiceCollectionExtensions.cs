using FluentValidation;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Diagnostics.HealthChecks;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;
using Microsoft.OpenApi;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Authorization;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.Logging;
using PadmashaliVidyaSetu.Api.Middleware;
using PadmashaliVidyaSetu.Api.Services.Admin;
using PadmashaliVidyaSetu.Api.Services.Auth;
using PadmashaliVidyaSetu.Api.Services.Locations;
using PadmashaliVidyaSetu.Api.Services.MasterData;
using PadmashaliVidyaSetu.Api.Services.Members;
using PadmashaliVidyaSetu.Api.Services.Verification;
using PadmashaliVidyaSetu.Api.Validators;

namespace PadmashaliVidyaSetu.Api.Configuration;

public static class ServiceCollectionExtensions
{
    // Configuration is always read lazily (through IOptions / IConfiguration resolved from DI), never while services
    // are being registered, so that later configuration sources - environment-specific overrides, secret stores,
    // test hosts - are honoured.

    public static IServiceCollection AddPvsOptions(this IServiceCollection services, IConfiguration configuration)
    {
        services.AddOptions<JwtOptions>().Bind(configuration.GetSection(JwtOptions.Section)).ValidateDataAnnotations().ValidateOnStart();
        services.AddOptions<PhoneVerificationOptions>().Bind(configuration.GetSection(PhoneVerificationOptions.Section))
            .ValidateDataAnnotations()
            .Validate<IHostEnvironment>((o, env) => env.IsDevelopment() || !o.ExposeCodeInResponse,
                "PhoneVerification:ExposeCodeInResponse may only be enabled in Development.")
            .Validate<IHostEnvironment>((o, env) => env.IsDevelopment() || !IsDevelopmentSender(o),
                "PhoneVerification:Sender 'Development' may only be used in Development.")
            .ValidateOnStart();
        services.AddOptions<SmsOptions>().Bind(configuration.GetSection(SmsOptions.Section))
            .ValidateDataAnnotations()
            .Validate<IOptions<PhoneVerificationOptions>>(
                (sms, verification) => !IsSender(verification.Value, VerificationSenders.SmsGatewayHub) || !sms.MissingSettings().Any(),
                "PhoneVerification:Sender is SmsGatewayHub but SMS settings are incomplete (SMS:APIKey, OTPSenderId, " +
                "OTPTemplateId, OTPEntityId, OTPTemplate with a {#...#} variable, https SMSURL).")
            .ValidateOnStart();
        services.AddOptions<RegistrationOptions>().Bind(configuration.GetSection(RegistrationOptions.Section)).ValidateDataAnnotations().ValidateOnStart();
        services.AddOptions<PinCodeLookupOptions>().Bind(configuration.GetSection(PinCodeLookupOptions.Section)).ValidateDataAnnotations().ValidateOnStart();
        services.AddOptions<RateLimitingOptions>().Bind(configuration.GetSection(RateLimitingOptions.Section));
        services.AddOptions<DatabaseOptions>().Bind(configuration.GetSection(DatabaseOptions.Section));
        services.AddOptions<CorsSettings>().Bind(configuration.GetSection(CorsSettings.Section));
        return services;
    }

    public static IServiceCollection AddPvsData(this IServiceCollection services)
    {
        services.AddDbContext<AppDbContext>((sp, options) =>
        {
            var connectionString = sp.GetRequiredService<IConfiguration>().GetConnectionString("DefaultConnection");
            if (string.IsNullOrWhiteSpace(connectionString))
                throw new InvalidOperationException(
                    "ConnectionStrings:DefaultConnection is not configured. Set it in appsettings.Development.json (LocalDB) " +
                    "or via the ConnectionStrings__DefaultConnection environment variable.");

            options.UsePvsSqlServer(connectionString, sql =>
            {
                sql.EnableRetryOnFailure(maxRetryCount: 5, maxRetryDelay: TimeSpan.FromSeconds(10), errorNumbersToAdd: null);
                sql.MigrationsAssembly(typeof(AppDbContext).Assembly.GetName().Name);
            });
        });
        return services;
    }

    private static bool IsDevelopmentSender(PhoneVerificationOptions o) => IsSender(o, VerificationSenders.Development);

    private static bool IsSender(PhoneVerificationOptions o, string sender) =>
        o.Sender.Equals(sender, StringComparison.OrdinalIgnoreCase);

    public static IServiceCollection AddPvsAuthentication(this IServiceCollection services)
    {
        services.AddHttpContextAccessor();
        services.AddScoped<ICurrentUserService, HttpCurrentUserService>();
        services.AddSingleton<SecurityKeys>();
        services.AddSingleton<ITokenService, TokenService>();
        services.AddSingleton<AdminPasswords>();

        services.AddAuthentication(JwtBearerDefaults.AuthenticationScheme).AddJwtBearer();
        services.AddOptions<JwtBearerOptions>(JwtBearerDefaults.AuthenticationScheme)
            .Configure<IOptions<JwtOptions>, SecurityKeys>((bearer, jwt, keys) =>
            {
                bearer.MapInboundClaims = false;
                bearer.TokenValidationParameters = new TokenValidationParameters
                {
                    ValidateIssuer = true,
                    ValidIssuer = jwt.Value.Issuer,
                    ValidateAudience = true,
                    ValidAudience = jwt.Value.Audience,
                    ValidateIssuerSigningKey = true,
                    IssuerSigningKey = keys.JwtSigningKey,
                    ValidateLifetime = true,
                    ClockSkew = TimeSpan.FromSeconds(30),
                    NameClaimType = PvsClaimTypes.Subject,
                    RoleClaimType = PvsClaimTypes.Role,
                };
                bearer.Events = new JwtBearerEvents
                {
                    OnChallenge = async context =>
                    {
                        context.HandleResponse();
                        var expired = context.AuthenticateFailure is SecurityTokenExpiredException;
                        if (expired) context.Response.Headers["X-Token-Expired"] = "true";
                        await ExceptionHandlingMiddleware.WriteAsync(context.HttpContext, StatusCodes.Status401Unauthorized,
                            ApiResponse.Fail(expired ? "Your session has expired." : "Please sign in to continue."));
                    },
                    OnForbidden = context => ExceptionHandlingMiddleware.WriteAsync(context.HttpContext,
                        StatusCodes.Status403Forbidden, ApiResponse.Fail("You do not have access to this information.")),
                };
            });

        services.AddAuthorization(options => options.AddPvsPolicies());
        return services;
    }

    public static IServiceCollection AddPvsServices(this IServiceCollection services)
    {
        services.AddSingleton(TimeProvider.System);
        services.AddScoped<IAuditLogger, AuditLogger>();
        services.AddScoped<IAuthService, AuthService>();
        services.AddScoped<IMasterDataService, MasterDataService>();
        services.AddScoped<LocationResolver>();
        services.AddScoped<IPinCodeLookupService, PinCodeLookupService>();
        services.AddScoped<IRegistrationIdGenerator, RegistrationIdGenerator>();
        services.AddScoped<IRegistrationService, RegistrationService>();
        services.AddSingleton<IProfileCompletionService, ProfileCompletionService>();
        services.AddScoped<IMemberService, MemberService>();
        services.AddScoped<IAdminMemberService, AdminMemberService>();
        services.AddScoped<IAdminReportService, AdminReportService>();
        services.AddScoped<IAdminListService, AdminListService>();
        services.AddScoped<IOtherValueService, OtherValueService>();
        services.AddScoped<IAdminUserService, AdminUserService>();
        services.AddScoped<ILocationReviewService, LocationReviewService>();
        services.AddScoped<IBrandingService, BrandingService>();
        services.AddScoped<IAppVersionService, AppVersionService>();

        services.AddHttpClient<IPinCodeProvider, IndiaPostPinCodeProvider>((sp, client) =>
        {
            var o = sp.GetRequiredService<IOptions<PinCodeLookupOptions>>().Value;
            client.BaseAddress = new Uri(o.BaseUrl);
            client.Timeout = TimeSpan.FromSeconds(o.TimeoutSeconds);
        });

        services.AddSingleton<DevelopmentVerificationCodeSender>();
        services.AddSingleton<NotConfiguredVerificationCodeSender>();
        services.AddHttpClient<SmsGatewayHubVerificationCodeSender>((sp, client) =>
                client.Timeout = TimeSpan.FromSeconds(sp.GetRequiredService<IOptions<SmsOptions>>().Value.TimeoutSeconds))
            // The request URL carries the API key and the code: never let HttpClient log it.
            .RemoveAllLoggers();
        services.AddScoped<IVerificationCodeSender>(sp =>
        {
            var verification = sp.GetRequiredService<IOptions<PhoneVerificationOptions>>().Value;
            if (IsSender(verification, VerificationSenders.SmsGatewayHub))
                return sp.GetRequiredService<SmsGatewayHubVerificationCodeSender>();
            if (IsDevelopmentSender(verification))
                return sp.GetRequiredService<DevelopmentVerificationCodeSender>();
            return sp.GetRequiredService<NotConfiguredVerificationCodeSender>();
        });

        services.AddValidatorsFromAssemblyContaining<RegisterMemberRequestValidator>(ServiceLifetime.Singleton);
        return services;
    }

    public static IServiceCollection AddPvsApi(this IServiceCollection services)
    {
        services.AddControllers(o => o.Filters.Add<ValidationFilter>())
            .ConfigureApiBehaviorOptions(o =>
            {
                // Malformed JSON / type mismatches use the same envelope as validation failures.
                o.InvalidModelStateResponseFactory = context =>
                {
                    var errors = context.ModelState
                        .Where(kv => kv.Value?.Errors.Count > 0)
                        .SelectMany(kv => kv.Value!.Errors.Select(_ => new ApiError(
                            ValidationFilter.ToJsonPath(kv.Key.TrimStart('$', '.')), "The value is not valid.")))
                        .ToList();
                    return new BadRequestObjectResult(ApiResponse.Fail("The request is not valid.", errors));
                };
            });

        services.AddOpenApi(o => o.AddDocumentTransformer((document, _, _) =>
        {
            document.Info.Title = "Padmashali Vidya Sethu API";
            // No server list: Swagger UI then calls the host it was opened from (https behind App Service too).
            document.Servers = [];
            // "Authorize" button in Swagger UI: paste the accessToken from verification-codes/verify.
            document.Components ??= new OpenApiComponents();
            document.Components.SecuritySchemes ??= new Dictionary<string, IOpenApiSecurityScheme>();
            document.Components.SecuritySchemes["Bearer"] = new OpenApiSecurityScheme
            {
                Type = SecuritySchemeType.Http,
                Scheme = "bearer",
                BearerFormat = "JWT",
                Description = "Access token from POST /api/v1/auth/verification-codes/verify (without \"Bearer \").",
            };
            document.Security = [new OpenApiSecurityRequirement { [new OpenApiSecuritySchemeReference("Bearer", document)] = [] }];
            return Task.CompletedTask;
        }));
        services.AddHealthChecks().AddCheck<DatabaseHealthCheck>("database");

        services.AddCors();
        services.AddOptions<Microsoft.AspNetCore.Cors.Infrastructure.CorsOptions>()
            .Configure<IOptions<CorsSettings>, IHostEnvironment>((cors, settings, env) => cors.AddDefaultPolicy(p =>
            {
                var origins = settings.Value.AllowedOrigins;
                var anyLocalhost = settings.Value.AllowAnyLocalhostOrigin && env.IsDevelopment();
                if (origins.Length == 0 && !anyLocalhost) return;
                p.SetIsOriginAllowed(origin => origins.Contains(origin, StringComparer.OrdinalIgnoreCase)
                        || (anyLocalhost && IsLocalhost(origin)))
                    .AllowAnyHeader()
                    .AllowAnyMethod();
            }));
        return services;
    }

    private static bool IsLocalhost(string origin) =>
        Uri.TryCreate(origin, UriKind.Absolute, out var uri) && uri.IsLoopback && uri.Scheme is "http" or "https";
}

public sealed class DatabaseHealthCheck(AppDbContext db) : IHealthCheck
{
    public async Task<HealthCheckResult> CheckHealthAsync(HealthCheckContext context, CancellationToken cancellationToken = default) =>
        await db.Database.CanConnectAsync(cancellationToken)
            ? HealthCheckResult.Healthy()
            : HealthCheckResult.Unhealthy("Database unreachable");
}
