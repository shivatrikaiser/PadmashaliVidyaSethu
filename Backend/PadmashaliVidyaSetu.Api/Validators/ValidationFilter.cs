using FluentValidation;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using PadmashaliVidyaSetu.Api.Common;

namespace PadmashaliVidyaSetu.Api.Validators;

/// <summary>
/// Runs the registered FluentValidation validator for every action argument before the action executes, and
/// answers 400 with field errors (camelCase JSON paths such as <c>permanentAddress.pinCode</c>) on failure.
/// </summary>
public sealed class ValidationFilter(IServiceProvider services) : IAsyncActionFilter
{
    public async Task OnActionExecutionAsync(ActionExecutingContext context, ActionExecutionDelegate next)
    {
        var errors = new List<ApiError>();
        foreach (var argument in context.ActionArguments.Values)
        {
            if (argument is null) continue;
            var validatorType = typeof(IValidator<>).MakeGenericType(argument.GetType());
            if (services.GetService(validatorType) is not IValidator validator) continue;

            var result = await validator.ValidateAsync(new ValidationContext<object>(argument), context.HttpContext.RequestAborted);
            errors.AddRange(result.Errors.Select(e => new ApiError(ToJsonPath(e.PropertyName), e.ErrorMessage)));
        }

        if (errors.Count > 0)
        {
            context.Result = new BadRequestObjectResult(ApiResponse.Fail("Please correct the highlighted fields.", errors));
            return;
        }

        await next();
    }

    /// <summary>"PermanentAddress.PinCode" → "permanentAddress.pinCode"; "DisabilityTypeIds[0]" → "disabilityTypeIds[0]".</summary>
    public static string? ToJsonPath(string? propertyName) =>
        string.IsNullOrEmpty(propertyName)
            ? null
            : string.Join('.', propertyName.Split('.').Select(p => p.Length == 0 ? p : char.ToLowerInvariant(p[0]) + p[1..]));
}
