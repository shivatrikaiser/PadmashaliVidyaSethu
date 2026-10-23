using Microsoft.Extensions.Options;
using Microsoft.Extensions.Time.Testing;
using PadmashaliVidyaSetu.Api.Configuration;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Validators;

namespace PadmashaliVidyaSetu.Api.Tests.Unit;

public sealed class RegisterMemberRequestValidatorTests
{
    // 2026-10-06 10:00 IST
    private static readonly FakeTimeProvider Clock = new(new DateTimeOffset(2026, 10, 6, 4, 30, 0, TimeSpan.Zero));
    private readonly RegisterMemberRequestValidator _validator = new(Options.Create(new RegistrationOptions()), Clock);

    private static readonly AddressRequest ValidAddress =
        new("House 12, Temple Road", null, "574201", "Puttur", null, 3, null, 11, 11, 1);

    private static RegisterMemberRequest Valid() => new(
        "Anu Suresh", "Suresh", "Lakshmi", new DateOnly(2012, 8, 15), 2, 1, 1, 13, null, null, 1,
        ValidAddress, true, null, false, null, null, true, true);

    private IEnumerable<string> ErrorFields(RegisterMemberRequest request) =>
        _validator.Validate(request).Errors.Select(e => ValidationFilter.ToJsonPath(e.PropertyName)!);

    [Fact]
    public void ValidRequest_Passes() => Assert.True(_validator.Validate(Valid()).IsValid);

    [Fact]
    public void KannadaName_IsAccepted() =>
        Assert.True(_validator.Validate(Valid() with { FullName = "ಅನು ಸುರೇಶ್" }).IsValid);

    [Theory]
    [InlineData("")]
    [InlineData("A")]
    [InlineData("Anu123")]
    [InlineData("<script>")]
    public void InvalidFullName_IsRejected(string name) =>
        Assert.Contains("fullName", ErrorFields(Valid() with { FullName = name }));

    [Fact]
    public void FutureDateOfBirth_IsRejected() =>
        Assert.Contains("dateOfBirth", ErrorFields(Valid() with { DateOfBirth = new DateOnly(2027, 1, 1) }));

    [Fact]
    public void FiveYearsOldToday_IsAccepted() =>
        Assert.True(_validator.Validate(Valid() with { DateOfBirth = new DateOnly(2021, 10, 6) }).IsValid);

    [Fact]
    public void OneDayShortOfFive_IsRejected() =>
        Assert.Contains("dateOfBirth", ErrorFields(Valid() with { DateOfBirth = new DateOnly(2021, 10, 7) }));

    [Fact]
    public void MissingDateOfBirth_IsRejectedWithoutCrashing() =>
        Assert.Contains("dateOfBirth", ErrorFields(Valid() with { DateOfBirth = null }));

    [Fact]
    public void ClassAndHighestEducationTogether_IsRejected() =>
        Assert.Contains("classId", ErrorFields(Valid() with { HighestEducationLevelId = 6 }));

    [Theory]
    [InlineData("57420")]
    [InlineData("5742011")]
    [InlineData("074201")]
    [InlineData("57A201")]
    public void InvalidPinCode_IsRejected(string pin) =>
        Assert.Contains("permanentAddress.pinCode", ErrorFields(Valid() with { PermanentAddress = ValidAddress with { PinCode = pin } }));

    [Fact]
    public void TalukMissing_WithoutNewTalukName_IsRejected() =>
        Assert.Contains("permanentAddress.talukId", ErrorFields(Valid() with { PermanentAddress = ValidAddress with { TalukId = null } }));

    [Fact]
    public void NewTalukName_InsteadOfTalukId_IsAccepted() =>
        Assert.True(_validator.Validate(Valid() with { PermanentAddress = ValidAddress with { TalukId = null, NewTalukName = "Kadaba" } }).IsValid);

    private static readonly AddressRequest AddressOutsideIndia =
        new("Flat 504, Al Nahda Tower", null, null, "Dubai", null, null, null, null, null, 2, "Dubai");

    [Fact]
    public void AddressOutsideIndia_WithoutPinDistrictOrTaluk_IsAccepted() =>
        Assert.True(_validator.Validate(Valid() with { PermanentAddress = AddressOutsideIndia }).IsValid);

    [Theory]
    [InlineData("SW1A 1AA")]
    [InlineData("10115")]
    [InlineData("K1A-0B1")]
    public void PostalCodeOutsideIndia_IsAccepted(string postalCode) =>
        Assert.True(_validator.Validate(Valid() with { PermanentAddress = AddressOutsideIndia with { PinCode = postalCode } }).IsValid);

    [Theory]
    [InlineData("#123")]
    [InlineData("12345678901")]
    public void InvalidPostalCodeOutsideIndia_IsRejected(string postalCode) =>
        Assert.Contains("permanentAddress.pinCode",
            ErrorFields(Valid() with { PermanentAddress = AddressOutsideIndia with { PinCode = postalCode } }));

    [Fact]
    public void AddressOutsideIndia_WithoutState_IsRejected() =>
        Assert.Contains("permanentAddress.stateId",
            ErrorFields(Valid() with { PermanentAddress = AddressOutsideIndia with { NewStateName = null } }));

    [Fact]
    public void CurrentAddressRequired_WhenNotSameAsPermanent() =>
        Assert.Contains("currentAddress", ErrorFields(Valid() with { CurrentAddressSameAsPermanent = false }));

    [Fact]
    public void Disabled_RequiresType() =>
        Assert.Contains("disabilityTypeIds", ErrorFields(Valid() with { IsDisabled = true }));

    [Fact]
    public void NotDisabled_RejectsTypes() =>
        Assert.Contains("disabilityTypeIds", ErrorFields(Valid() with { DisabilityTypeIds = [2] }));

    [Fact]
    public void PrivacyPolicy_MustBeAccepted() =>
        Assert.Contains("acceptPrivacyPolicy", ErrorFields(Valid() with { AcceptPrivacyPolicy = false }));
}
