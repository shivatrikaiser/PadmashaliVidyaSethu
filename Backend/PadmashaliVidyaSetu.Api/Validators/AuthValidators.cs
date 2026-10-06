using FluentValidation;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.DTOs;

namespace PadmashaliVidyaSetu.Api.Validators;

public sealed class RequestVerificationCodeRequestValidator : AbstractValidator<RequestVerificationCodeRequest>
{
    public RequestVerificationCodeRequestValidator()
    {
        RuleLevelCascadeMode = CascadeMode.Stop;
        RuleFor(x => x.MobileNumber)
            .NotEmpty().WithMessage("Please enter your mobile number.")
            .Must(m => MobileNumber.TryNormalize(m, out _)).WithMessage("Please enter a valid 10-digit mobile number.");
    }
}

public sealed class VerifyCodeRequestValidator : AbstractValidator<VerifyCodeRequest>
{
    public VerifyCodeRequestValidator()
    {
        RuleLevelCascadeMode = CascadeMode.Stop;
        RuleFor(x => x.ChallengeId).NotEmpty().WithMessage("Please request a verification code first.");
        RuleFor(x => x.Code)
            .NotEmpty().WithMessage("Please enter the 4-digit Phone Number Verification Code.")
            .Matches(@"^\d{4}$").WithMessage("The Phone Number Verification Code must be exactly 4 digits.");
    }
}

public sealed class RefreshTokenRequestValidator : AbstractValidator<RefreshTokenRequest>
{
    public RefreshTokenRequestValidator()
    {
        RuleFor(x => x.RefreshToken).NotEmpty().MaximumLength(200);
    }
}
