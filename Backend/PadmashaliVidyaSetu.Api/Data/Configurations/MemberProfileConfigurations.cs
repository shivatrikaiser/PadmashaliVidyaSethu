using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Entities.Members;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

internal static class MemberListChoiceMapping
{
    /// <summary>
    /// Member ↔ master-list link: PK (RegistrationId, {Item}Id), FK to the list (Other included),
    /// <c>OtherText</c> for the typed value when the OTHER row is chosen.
    /// </summary>
    public static void ConfigureMemberListChoice<T, TItem>(this EntityTypeBuilder<T> b, string table, string itemColumn)
        where T : MemberListChoice<TItem>
        where TItem : MasterDataEntity
    {
        b.ToTable(table);
        b.HasKey(e => new { e.RegistrationId, e.ItemId });
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);
        b.Property(e => e.ItemId).HasColumnName(itemColumn);
        b.Property(e => e.OtherText).HasMaxLength(ConfigurationExtensions.OtherTextLength);
        b.Property(e => e.CreatedDate).HasColumnType("datetime2(3)").HasDefaultValueSql("SYSUTCDATETIME()");
        b.Property(e => e.CreatedBy).HasMaxLength(ConfigurationExtensions.AuditUserLength);
        b.HasOne(e => e.Member).WithMany().HasForeignKey(e => e.RegistrationId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(e => e.Item).WithMany().HasForeignKey(e => e.ItemId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class MemberSkillConfiguration : IEntityTypeConfiguration<MemberSkill>
{
    public void Configure(EntityTypeBuilder<MemberSkill> b) =>
        b.ConfigureMemberListChoice<MemberSkill, Skill>("MemberSkills", "SkillId");
}

public class MemberInterestAreaConfiguration : IEntityTypeConfiguration<MemberInterestArea>
{
    public void Configure(EntityTypeBuilder<MemberInterestArea> b) =>
        b.ConfigureMemberListChoice<MemberInterestArea, InterestArea>("MemberInterestAreas", "InterestAreaId");
}

public class MemberSportConfiguration : IEntityTypeConfiguration<MemberSport>
{
    public void Configure(EntityTypeBuilder<MemberSport> b) =>
        b.ConfigureMemberListChoice<MemberSport, Sport>("MemberSports", "SportId");
}

public class MemberHobbyConfiguration : IEntityTypeConfiguration<MemberHobby>
{
    public void Configure(EntityTypeBuilder<MemberHobby> b) =>
        b.ConfigureMemberListChoice<MemberHobby, Hobby>("MemberHobbies", "HobbyId");
}

public class MemberCareerAspirationConfiguration : IEntityTypeConfiguration<MemberCareerAspiration>
{
    public void Configure(EntityTypeBuilder<MemberCareerAspiration> b) =>
        b.ConfigureMemberListChoice<MemberCareerAspiration, CareerOption>("MemberCareerAspirations", "CareerOptionId");
}

public class MemberCompetitiveExamConfiguration : IEntityTypeConfiguration<MemberCompetitiveExam>
{
    public void Configure(EntityTypeBuilder<MemberCompetitiveExam> b) =>
        b.ConfigureMemberListChoice<MemberCompetitiveExam, CompetitiveExam>("MemberCompetitiveExams", "CompetitiveExamId");
}

public class MemberEducationConfiguration : IEntityTypeConfiguration<MemberEducation>
{
    public void Configure(EntityTypeBuilder<MemberEducation> b)
    {
        b.ToTable("MemberEducation");
        b.HasKey(e => e.MemberEducationId);
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);
        b.Property(e => e.EducationLevelOtherText).HasMaxLength(ConfigurationExtensions.OtherTextLength);
        b.Property(e => e.CourseOtherText).HasMaxLength(ConfigurationExtensions.OtherTextLength);
        b.Property(e => e.BranchOtherText).HasMaxLength(ConfigurationExtensions.OtherTextLength);
        b.Property(e => e.BoardOtherText).HasMaxLength(ConfigurationExtensions.OtherTextLength);
        b.ConfigureAudit();

        b.HasOne(e => e.Member).WithMany().HasForeignKey(e => e.RegistrationId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(e => e.EducationLevel).WithMany().HasForeignKey(e => e.EducationLevelId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Course).WithMany().HasForeignKey(e => e.CourseId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Branch).WithMany().HasForeignKey(e => e.BranchId).OnDelete(DeleteBehavior.Restrict);
        b.HasOne(e => e.Board).WithMany().HasForeignKey(e => e.BoardId).OnDelete(DeleteBehavior.Restrict);
    }
}

public class AcademicAchievementConfiguration : IEntityTypeConfiguration<AcademicAchievement>
{
    public void Configure(EntityTypeBuilder<AcademicAchievement> b)
    {
        b.ToTable("AcademicAchievements");
        b.HasKey(e => e.AcademicAchievementId);
        b.Property(e => e.RegistrationId).HasMaxLength(11).IsFixedLength().IsUnicode(false);
        b.Property(e => e.AchievementTypeOtherText).HasMaxLength(ConfigurationExtensions.OtherTextLength);
        b.ConfigureAudit();

        b.HasOne(e => e.Member).WithMany().HasForeignKey(e => e.RegistrationId).OnDelete(DeleteBehavior.Cascade);
        b.HasOne(e => e.AchievementType).WithMany().HasForeignKey(e => e.AchievementTypeId).OnDelete(DeleteBehavior.Restrict);
    }
}
