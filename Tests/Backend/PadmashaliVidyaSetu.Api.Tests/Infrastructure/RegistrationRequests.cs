namespace PadmashaliVidyaSetu.Api.Tests.Infrastructure;

/// <summary>
/// Builds registration payloads using seeded master-data IDs.
/// Seed IDs: MemberStatus 1=Student 2=Working 3=Unemployed; Class 13=PUC 1; EducationLevel 6=Undergraduate;
/// Country 1=India; State 11=Karnataka; District 11=Dakshina Kannada; Taluk 3=Puttur; DisabilityType 2=Hearing, 8=Other.
/// </summary>
public static class RegistrationRequests
{
    public const int StatusStudent = 1, StatusWorking = 2, StatusUnemployed = 3;
    public const int ClassPuc1 = 13;
    public const int EducationUndergraduate = 6;
    public const int DisabilityHearing = 2, DisabilityOther = 8;

    public static object Address(string pin = FakePinCodeProvider.PutturPin, int? talukId = 3, string? newTalukName = null) => new
    {
        addressLine1 = "House 12, Temple Road",
        pinCode = pin,
        cityVillageName = "Puttur",
        talukId,
        newTalukName,
        districtId = 11,
        stateId = 11,
        countryId = 1,
    };

    public static Dictionary<string, object?> Student(string fullName = "Anu Suresh", int templeId = 1) => new()
    {
        ["fullName"] = fullName,
        ["fatherName"] = "Suresh",
        ["motherName"] = "Lakshmi",
        ["dateOfBirth"] = "2012-08-15",
        ["genderId"] = 2,
        ["templeId"] = templeId,
        ["memberStatusId"] = StatusStudent,
        ["classId"] = ClassPuc1,
        ["organisationId"] = 1,
        ["permanentAddress"] = Address(),
        ["currentAddressSameAsPermanent"] = true,
        ["isDisabled"] = false,
        ["acceptPrivacyPolicy"] = true,
        ["guardianConsent"] = true,
    };

    public static Dictionary<string, object?> Adult(int statusId, string fullName = "Ravi Kumar")
    {
        var r = Student(fullName);
        r["dateOfBirth"] = "1998-01-20";
        r["memberStatusId"] = statusId;
        r["classId"] = null;
        r["highestEducationLevelId"] = EducationUndergraduate;
        r["guardianConsent"] = false;
        return r;
    }
}
