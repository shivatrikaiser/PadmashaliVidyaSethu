namespace PadmashaliVidyaSetu.Api.Common;

public static class AgeCalculator
{
    /// <summary>Age in completed years on <paramref name="today"/>.</summary>
    public static int AgeOn(DateOnly dateOfBirth, DateOnly today)
    {
        var age = today.Year - dateOfBirth.Year;
        if (today < dateOfBirth.AddYears(age)) age--;
        return age;
    }
}
