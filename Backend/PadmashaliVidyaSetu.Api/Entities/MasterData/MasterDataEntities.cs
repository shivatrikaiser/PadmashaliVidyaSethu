using PadmashaliVidyaSetu.Api.Entities.Common;

namespace PadmashaliVidyaSetu.Api.Entities.MasterData;

/// <summary>Padmashali temple. <see cref="MasterDataEntity.Code"/> is the 2-digit code used in Registration IDs.</summary>
public class Temple : MasterDataEntity;

/// <summary>Padmashali organisation a member may be linked to. Code <c>NONE</c> = not linked.</summary>
public class Organisation : MasterDataEntity;

public class Gender : MasterDataEntity;

/// <summary>Current Status: STUDENT, WORKING, UNEMPLOYED. Conditional UI/validation keys off the code.</summary>
public class MemberStatus : MasterDataEntity;

/// <summary>"Class Studying" values shown when Current Status = Student (LKG ... Postgraduate).</summary>
public class SchoolClass : MasterDataEntity
{
    /// <summary>Broad education stage, used to decide which profile questions are relevant.</summary>
    public string Stage { get; set; } = EducationStages.Other;
}

/// <summary>"Highest Education" values shown when Current Status = Working / Unemployed.</summary>
public class EducationLevel : MasterDataEntity;

public class Course : MasterDataEntity;
public class Branch : MasterDataEntity;
public class Board : MasterDataEntity;
public class University : MasterDataEntity;
public class CareerOption : MasterDataEntity;
public class InterestArea : MasterDataEntity;

public class Skill : MasterDataEntity
{
    /// <summary>One of <see cref="SkillCategories"/>.</summary>
    public string Category { get; set; } = SkillCategories.General;
}

public class Sport : MasterDataEntity;
public class Hobby : MasterDataEntity;
public class CompetitiveExam : MasterDataEntity;
public class AchievementType : MasterDataEntity;

/// <summary>
/// Disability types. Members may add a new type via "Other - please specify";
/// such rows are flagged <see cref="IsUserSubmitted"/> so administrators can review them.
/// </summary>
public class DisabilityType : MasterDataEntity
{
    public bool IsUserSubmitted { get; set; }
}

public class CommunicationTopic : MasterDataEntity;
public class CommunicationChannel : MasterDataEntity;

public static class EducationStages
{
    public const string PrePrimary = "PrePrimary";
    public const string Primary = "Primary";
    public const string HighSchool = "HighSchool";
    public const string PreUniversity = "PreUniversity";
    public const string Vocational = "Vocational";
    public const string UnderGraduate = "UnderGraduate";
    public const string PostGraduate = "PostGraduate";
    public const string Professional = "Professional";
    public const string Other = "Other";

    public static readonly string[] All =
        [PrePrimary, Primary, HighSchool, PreUniversity, Vocational, UnderGraduate, PostGraduate, Professional, Other];
}

public static class SkillCategories
{
    public const string Technical = "Technical";
    public const string General = "General";
    public const string Creative = "Creative";

    public static readonly string[] All = [Technical, General, Creative];
}

/// <summary>Stable codes that application logic depends on. Display names stay editable.</summary>
public static class MasterCodes
{
    public const string StatusStudent = "STUDENT";
    public const string StatusWorking = "WORKING";
    public const string StatusUnemployed = "UNEMPLOYED";

    public const string DisabilityOther = "OTHER";
    public const string OrganisationNone = "NONE";
    public const string CountryIndia = "IN";
}
