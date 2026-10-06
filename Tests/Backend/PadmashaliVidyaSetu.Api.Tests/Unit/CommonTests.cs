using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Services.Locations;
using PadmashaliVidyaSetu.Api.Services.Members;

namespace PadmashaliVidyaSetu.Api.Tests.Unit;

public sealed class CommonTests
{
    [Theory]
    [InlineData("9876543210", "+919876543210")]
    [InlineData("+91 98765 43210", "+919876543210")]
    [InlineData("919876543210", "+919876543210")]
    [InlineData("09876543210", "+919876543210")]
    [InlineData("6000000000", "+916000000000")]
    public void MobileNumber_Normalizes(string input, string expected)
    {
        Assert.True(MobileNumber.TryNormalize(input, out var e164));
        Assert.Equal(expected, e164);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("98765")]
    [InlineData("5876543210")]
    [InlineData("98765432100")]
    [InlineData("+1 415 555 0100")]
    public void MobileNumber_RejectsInvalid(string? input) =>
        Assert.False(MobileNumber.TryNormalize(input, out _));

    [Fact]
    public void MobileNumber_MaskKeepsOnlyLastFourDigits() =>
        Assert.Equal("+91******3210", MobileNumber.Mask("+919876543210"));

    [Theory]
    [InlineData("2010-08-15", "2026-08-14", 15)]
    [InlineData("2010-08-15", "2026-08-15", 16)]
    [InlineData("2012-02-29", "2026-02-27", 13)] // leap-day birthdays count from 28 Feb in non-leap years
    [InlineData("2012-02-29", "2026-02-28", 14)]
    [InlineData("2012-02-29", "2026-03-01", 14)]
    public void AgeCalculator_CountsCompletedYears(string dob, string today, int expected) =>
        Assert.Equal(expected, AgeCalculator.AgeOn(DateOnly.Parse(dob), DateOnly.Parse(today)));

    [Theory]
    [InlineData("01", 1, "PVS-01-0001")]
    [InlineData("16", 42, "PVS-16-0042")]
    [InlineData("05", 9999, "PVS-05-9999")]
    public void RegistrationId_Format(string templeCode, int sequence, string expected) =>
        Assert.Equal(expected, RegistrationIdGenerator.Format(templeCode, sequence));

    [Theory]
    [InlineData("Shimoga", "shimoga")]
    [InlineData("Jammu & Kashmir", "jammuandkashmir")]
    [InlineData(" Bangalore  North ", "bangalorenorth")]
    [InlineData("Puttur(D.K.)", "putturdk")]
    public void LocationNormalize_IgnoresCaseSpacingPunctuation(string input, string expected) =>
        Assert.Equal(expected, LocationResolver.Normalize(input));

    [Theory]
    [InlineData("  Anu   Suresh ", "Anu Suresh")]
    [InlineData(null, "")]
    public void Tidy_CollapsesWhitespace(string? input, string expected) =>
        Assert.Equal(expected, input.Tidy());
}
