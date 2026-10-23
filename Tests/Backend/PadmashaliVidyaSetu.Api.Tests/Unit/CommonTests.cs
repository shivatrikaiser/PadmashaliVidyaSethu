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
    [InlineData("+971 50 123 4567", "+971501234567")] // outside India: with the country code
    [InlineData("00971-50-123-4567", "+971501234567")]
    [InlineData("+1 415 555 0100", "+14155550100")]
    [InlineData("+44 7911 123456", "+447911123456")]
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
    [InlineData("+91 12345")] // +91 still follows the Indian rules
    [InlineData("+91 5876543210")]
    [InlineData("+0 123 456 789")]
    [InlineData("+1234567")] // fewer than 8 digits
    [InlineData("+1234567890123456")] // more than 15 digits
    [InlineData("971501234567")] // without "+" a number is read as Indian
    public void MobileNumber_RejectsInvalid(string? input) =>
        Assert.False(MobileNumber.TryNormalize(input, out _));

    [Theory]
    [InlineData("+919876543210", true)]
    [InlineData("+971501234567", false)]
    public void MobileNumber_IsIndian(string e164, bool expected) => Assert.Equal(expected, MobileNumber.IsIndian(e164));

    [Theory]
    [InlineData(" Anu.Suresh@Example.COM ", "anu.suresh@example.com")]
    [InlineData("a+tag@mail.co.ae", "a+tag@mail.co.ae")]
    public void EmailAddress_Normalizes(string input, string expected)
    {
        Assert.True(EmailAddress.TryNormalize(input, out var email));
        Assert.Equal(expected, email);
    }

    [Theory]
    [InlineData(null)]
    [InlineData("")]
    [InlineData("anu")]
    [InlineData("anu@example")]
    [InlineData("anu @example.com")]
    [InlineData("anu@-example.com")]
    public void EmailAddress_RejectsInvalid(string? input) => Assert.False(EmailAddress.TryNormalize(input, out _));

    [Fact]
    public void EmailAddress_Mask_KeepsDomain() => Assert.Equal("an********@example.com", EmailAddress.Mask("anusuresh1@example.com"));

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
