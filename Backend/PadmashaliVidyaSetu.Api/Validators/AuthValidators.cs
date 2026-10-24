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
            .Must(m => MobileNumber.TryNormalize(m, out _)).WithMessage("Please enter a valid mobile number. For a number outside India, include the country code (e.g. +971...).");
    }
}

/// <summary>Same limits as the website form (name 2-100, message 10-2000, email or phone, consent).</summary>
public sealed class EnquiryRequestValidator : AbstractValidator<EnquiryRequest>
{
    private static readonly System.Text.RegularExpressions.Regex Phone = new(@"^\+?[0-9 ()\-]{7,20}$");

    public EnquiryRequestValidator()
    {
        RuleLevelCascadeMode = CascadeMode.Stop;
        RuleFor(x => x.Category)
            .Must(c => c is not null && Services.Website.EnquiryService.Categories.ContainsKey(c))
            .WithMessage("Please choose what your enquiry is about.");
        RuleFor(x => x.Name)
            .NotEmpty().WithMessage("Please enter your name.")
            .Must(n => n.Tidy().Length is >= 2 and <= 100).WithMessage("Please enter your name (2 to 100 characters).");
        RuleFor(x => x.Organization).MaximumLength(150);
        RuleFor(x => x.Email)
            .Must(e => EmailAddress.TryNormalize(e, out _)).WithMessage("Please enter a valid email address.")
            .When(x => !string.IsNullOrWhiteSpace(x.Email));
        RuleFor(x => x.Phone)
            .Must(p => Phone.IsMatch(p!.Trim())).WithMessage("Please enter a valid phone number.")
            .When(x => !string.IsNullOrWhiteSpace(x.Phone));
        RuleFor(x => x)
            .Must(x => !string.IsNullOrWhiteSpace(x.Email) || !string.IsNullOrWhiteSpace(x.Phone))
            .OverridePropertyName("email")
            .WithMessage("Please give an email address, a phone number, or both.");
        RuleFor(x => x.Message)
            .NotEmpty().WithMessage("Please enter your message.")
            .Must(m => m!.Trim().Length is >= 10 and <= 2000).WithMessage("Please write between 10 and 2000 characters.");
        RuleFor(x => x.Consent).Equal(true).WithMessage("Please agree that we may use these details to reply.");
        RuleFor(x => x.Page).MaximumLength(200);
        RuleFor(x => x.Locale).MaximumLength(10);
    }
}

public sealed class RequestEmailCodeRequestValidator : AbstractValidator<RequestEmailCodeRequest>
{
    public RequestEmailCodeRequestValidator()
    {
        RuleLevelCascadeMode = CascadeMode.Stop;
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Please enter the email address.")
            .Must(e => EmailAddress.TryNormalize(e, out _)).WithMessage("Please enter a valid email address.");
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
