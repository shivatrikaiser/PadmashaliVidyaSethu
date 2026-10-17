using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.MasterData;

namespace PadmashaliVidyaSetu.Api.Entities.Members;

/// <summary>
/// A member's choice from a master list (skills, sports, ...). Choosing an existing value stores only its key;
/// choosing the list's OTHER row stores the OTHER key and the typed value in <see cref="OtherText"/>.
/// </summary>
public abstract class MemberListChoice<TItem> where TItem : MasterDataEntity
{
    public string RegistrationId { get; set; } = string.Empty;
    public Member Member { get; set; } = null!;

    public int ItemId { get; set; }
    public TItem Item { get; set; } = null!;

    /// <summary>Typed text when <see cref="Item"/> is the OTHER row; otherwise null.</summary>
    public string? OtherText { get; set; }

    public DateTime CreatedDate { get; set; }
    public string? CreatedBy { get; set; }
}

public class MemberSkill : MemberListChoice<Skill>;
public class MemberInterestArea : MemberListChoice<InterestArea>;
public class MemberSport : MemberListChoice<Sport>;
public class MemberHobby : MemberListChoice<Hobby>;
public class MemberCareerAspiration : MemberListChoice<CareerOption>;
public class MemberCompetitiveExam : MemberListChoice<CompetitiveExam>;

/// <summary>One education record (school, PUC, degree, ...). Each list reference has its own "Other" text column.</summary>
public class MemberEducation : AuditableEntity
{
    public int MemberEducationId { get; set; }

    public string RegistrationId { get; set; } = string.Empty;
    public Member Member { get; set; } = null!;

    public int EducationLevelId { get; set; }
    public EducationLevel EducationLevel { get; set; } = null!;
    public string? EducationLevelOtherText { get; set; }

    public int? CourseId { get; set; }
    public Course? Course { get; set; }
    public string? CourseOtherText { get; set; }

    public int? BranchId { get; set; }
    public Branch? Branch { get; set; }
    public string? BranchOtherText { get; set; }

    public int? BoardId { get; set; }
    public Board? Board { get; set; }
    public string? BoardOtherText { get; set; }
}

/// <summary>One academic achievement of a member.</summary>
public class AcademicAchievement : AuditableEntity
{
    public int AcademicAchievementId { get; set; }

    public string RegistrationId { get; set; } = string.Empty;
    public Member Member { get; set; } = null!;

    public int AchievementTypeId { get; set; }
    public AchievementType AchievementType { get; set; } = null!;
    public string? AchievementTypeOtherText { get; set; }
}
