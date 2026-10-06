using FluentValidation;
using Microsoft.Extensions.Options;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;

namespace PadmashaliVidyaSetu.Api.Validators;

public sealed class RegisterMemberRequestValidator : AbstractValidator<RegisterMemberRequest>
{
    /// <summary>Letters in any script (so Kannada names work), spaces, dots, apostrophes and hyphens.</summary>
    public const string NamePattern = @"^[\p{L}\p{M}][\p{L}\p{M} .'\-]*$";

    public RegisterMemberRequestValidator(IOptions<RegistrationOptions> options, TimeProvider clock)
    {
        RuleLevelCascadeMode = CascadeMode.Stop;
        var o = options.Value;

        RuleFor(x => x.FullName).PersonName("full name");
        RuleFor(x => x.FatherName).PersonName("father's name");
        RuleFor(x => x.MotherName).PersonName("mother's name");

        RuleFor(x => x.DateOfBirth)
            .NotNull().WithMessage("Please select the date of birth.")
            .Must(d => d <= clock.TodayInIndia()).WithMessage("Date of birth cannot be in the future.")
            .Must(d => AgeCalculator.AgeOn(d!.Value, clock.TodayInIndia()) >= o.MinimumAge)
                .WithMessage($"Members must be at least {o.MinimumAge} years old.")
            .Must(d => AgeCalculator.AgeOn(d!.Value, clock.TodayInIndia()) <= o.MaximumAge)
                .WithMessage("Please check the date of birth.");

        RuleFor(x => x.GenderId).NotNull().GreaterThan(0).WithMessage("Please select a gender.");
        RuleFor(x => x.TempleId).NotNull().GreaterThan(0).WithMessage("Please select your temple.");
        RuleFor(x => x.MemberStatusId).NotNull().GreaterThan(0).WithMessage("Please select your current status.");
        RuleFor(x => x.OrganisationId).NotNull().GreaterThan(0).WithMessage("Please select an organisation option.");

        RuleFor(x => x)
            .Must(x => x.ClassId is null || x.HighestEducationLevelId is null)
            .OverridePropertyName("classId")
            .WithMessage("Provide either Class Studying or Highest Education, not both.");

        RuleFor(x => x.PermanentAddress)
            .NotNull().WithMessage("Please enter the permanent address.")
            .SetValidator(new AddressRequestValidator()!);

        RuleFor(x => x.CurrentAddress)
            .NotNull().WithMessage("Please enter the current address.")
            .SetValidator(new AddressRequestValidator()!)
            .When(x => !x.CurrentAddressSameAsPermanent);

        // Rules 5/6: disability types only when "Is Disabled = Yes".
        RuleFor(x => x.DisabilityTypeIds)
            .NotEmpty().WithMessage("Please select the type of disability.")
            .When(x => x.IsDisabled);
        RuleFor(x => x.DisabilityTypeIds)
            .Empty().WithMessage("Disability type applies only when 'Is Disabled' is Yes.")
            .When(x => !x.IsDisabled);
        RuleForEach(x => x.DisabilityTypeIds).GreaterThan(0);
        RuleFor(x => x.OtherDisabilityDescription)
            .MaximumLength(100)
            .Matches(@"^[\p{L}\p{M}\d][\p{L}\p{M}\d .,'/()\-]*$").WithMessage("Please use letters and numbers only.")
            .When(x => !string.IsNullOrWhiteSpace(x.OtherDisabilityDescription));

        RuleFor(x => x.AcceptPrivacyPolicy)
            .Equal(true).WithMessage("Please accept the privacy policy to continue.");
    }
}

public sealed class AddressRequestValidator : AbstractValidator<AddressRequest>
{
    public AddressRequestValidator()
    {
        RuleLevelCascadeMode = CascadeMode.Stop;
        RuleFor(x => x.AddressLine1)
            .NotEmpty().WithMessage("Please enter the house / street address.")
            .MinimumLength(3).WithMessage("Address is too short.")
            .MaximumLength(200);
        RuleFor(x => x.AddressLine2).MaximumLength(200);
        RuleFor(x => x.PinCode)
            .NotEmpty().WithMessage("Please enter the PIN code.")
            .Matches(@"^[1-9]\d{5}$").WithMessage("PIN code must be exactly 6 digits.");
        RuleFor(x => x.CityVillageName)
            .NotEmpty().WithMessage("Please enter the city / village.")
            .MaximumLength(150);
        RuleFor(x => x.CountryId).NotNull().GreaterThan(0).WithMessage("Please select the country.");
        RuleFor(x => x.StateId).NotNull().GreaterThan(0).WithMessage("Please select the state.");
        RuleFor(x => x.DistrictId).NotNull().GreaterThan(0).WithMessage("Please select the district.");
        RuleFor(x => x.TalukId)
            .NotNull().WithMessage("Please select the taluk.")
            .When(x => string.IsNullOrWhiteSpace(x.NewTalukName));
        RuleFor(x => x.NewTalukName)
            .MinimumLength(2).MaximumLength(100)
            .Matches(RegisterMemberRequestValidator.NamePattern).WithMessage("Please use letters only for the taluk name.")
            .When(x => x.TalukId is null && !string.IsNullOrWhiteSpace(x.NewTalukName));
    }
}

internal static class ValidatorExtensions
{
    public static IRuleBuilderOptions<T, string?> PersonName<T>(this IRuleBuilder<T, string?> rule, string label) =>
        rule
            .NotEmpty().WithMessage($"Please enter the {label}.")
            .Must(v => v.Tidy().Length >= 2).WithMessage($"The {label} is too short.")
            .MaximumLength(150).WithMessage($"The {label} is too long.")
            .Matches(RegisterMemberRequestValidator.NamePattern).WithMessage($"The {label} can contain letters, spaces, dots and hyphens only.");
}
