using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using PadmashaliVidyaSetu.Api.Data.Seed;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.MasterData;

namespace PadmashaliVidyaSetu.Api.Data.Configurations;

public class TempleConfiguration : IEntityTypeConfiguration<Temple>
{
    public void Configure(EntityTypeBuilder<Temple> b)
    {
        b.ConfigureMasterData("Temples", "TempleId");
        b.Property(e => e.Code).HasColumnName("TempleCode").HasMaxLength(2);
        b.Property(e => e.Name).HasColumnName("TempleName").HasMaxLength(200); // name with place
        // The temple code is embedded in Registration IDs (PVS-TT-NNNN) so it must be exactly two digits.
        b.ToTable(t => t.HasCheckConstraint("CK_Temples_TempleCode", "[TempleCode] LIKE '[0-9][0-9]'"));
        b.HasData(SeedData.Temples);
    }
}

public class OrganisationConfiguration : IEntityTypeConfiguration<Organisation>
{
    public void Configure(EntityTypeBuilder<Organisation> b)
    {
        b.ConfigureMasterData("Organisations", "OrganisationId");
        b.Property(e => e.Code).HasColumnName("OrganisationCode");
        b.Property(e => e.Name).HasColumnName("OrganisationName");
        b.HasData(SeedData.Organisations);
    }
}

public class GenderConfiguration : IEntityTypeConfiguration<Gender>
{
    public void Configure(EntityTypeBuilder<Gender> b)
    {
        b.ConfigureMasterData("Genders", "GenderId");
        b.HasData(SeedData.Genders);
    }
}

public class MemberStatusConfiguration : IEntityTypeConfiguration<MemberStatus>
{
    public void Configure(EntityTypeBuilder<MemberStatus> b)
    {
        b.ConfigureMasterData("MemberStatuses", "MemberStatusId");
        b.HasData(SeedData.MemberStatuses);
    }
}

public class SchoolClassConfiguration : IEntityTypeConfiguration<SchoolClass>
{
    public void Configure(EntityTypeBuilder<SchoolClass> b)
    {
        b.ConfigureMasterData("Classes", "ClassId");
        b.Property(e => e.Stage).HasMaxLength(20).IsUnicode(false).IsRequired();
        b.ToTable(t => t.HasCheckConstraint("CK_Classes_Stage",
            $"[Stage] IN ({string.Join(", ", EducationStages.All.Select(s => $"'{s}'"))})"));
        b.HasData(SeedData.Classes);
    }
}

public class EducationLevelConfiguration : IEntityTypeConfiguration<EducationLevel>
{
    public void Configure(EntityTypeBuilder<EducationLevel> b)
    {
        b.ConfigureMasterData("EducationLevels", "EducationLevelId");
        b.HasData(SeedData.EducationLevels);
    }
}

public class CourseConfiguration : IEntityTypeConfiguration<Course>
{
    public void Configure(EntityTypeBuilder<Course> b)
    {
        b.ConfigureMasterData("Courses", "CourseId");
        b.HasData(SeedData.Courses);
    }
}

public class BranchConfiguration : IEntityTypeConfiguration<Branch>
{
    public void Configure(EntityTypeBuilder<Branch> b)
    {
        b.ConfigureMasterData("Branches", "BranchId");
        b.HasData(SeedData.Branches);
    }
}

public class BoardConfiguration : IEntityTypeConfiguration<Board>
{
    public void Configure(EntityTypeBuilder<Board> b)
    {
        b.ConfigureMasterData("Boards", "BoardId");
        b.HasData(SeedData.Boards);
    }
}

public class UniversityConfiguration : IEntityTypeConfiguration<University>
{
    public void Configure(EntityTypeBuilder<University> b)
    {
        b.ConfigureMasterData("Universities", "UniversityId");
        b.HasData(SeedData.Universities);
    }
}

public class CareerOptionConfiguration : IEntityTypeConfiguration<CareerOption>
{
    public void Configure(EntityTypeBuilder<CareerOption> b)
    {
        b.ConfigureMasterData("CareerOptions", "CareerOptionId");
        b.HasData(SeedData.CareerOptions);
    }
}

public class InterestAreaConfiguration : IEntityTypeConfiguration<InterestArea>
{
    public void Configure(EntityTypeBuilder<InterestArea> b)
    {
        b.ConfigureMasterData("InterestAreas", "InterestAreaId");
        b.HasData(SeedData.InterestAreas);
    }
}

public class SkillConfiguration : IEntityTypeConfiguration<Skill>
{
    public void Configure(EntityTypeBuilder<Skill> b)
    {
        b.ConfigureMasterData("Skills", "SkillId");
        b.Property(e => e.Category).HasMaxLength(20).IsUnicode(false).IsRequired();
        b.HasIndex(e => new { e.Category, e.IsActive, e.DisplayOrder });
        b.ToTable(t => t.HasCheckConstraint("CK_Skills_Category",
            $"[Category] IN ({string.Join(", ", SkillCategories.All.Select(s => $"'{s}'"))})"));
        b.HasData(SeedData.Skills);
    }
}

public class SportConfiguration : IEntityTypeConfiguration<Sport>
{
    public void Configure(EntityTypeBuilder<Sport> b)
    {
        b.ConfigureMasterData("Sports", "SportId");
        b.HasData(SeedData.Sports);
    }
}

public class HobbyConfiguration : IEntityTypeConfiguration<Hobby>
{
    public void Configure(EntityTypeBuilder<Hobby> b)
    {
        b.ConfigureMasterData("Hobbies", "HobbyId");
        b.HasData(SeedData.Hobbies);
    }
}

public class CompetitiveExamConfiguration : IEntityTypeConfiguration<CompetitiveExam>
{
    public void Configure(EntityTypeBuilder<CompetitiveExam> b)
    {
        b.ConfigureMasterData("CompetitiveExams", "CompetitiveExamId");
        b.HasData(SeedData.CompetitiveExams);
    }
}

public class AchievementTypeConfiguration : IEntityTypeConfiguration<AchievementType>
{
    public void Configure(EntityTypeBuilder<AchievementType> b)
    {
        b.ConfigureMasterData("AchievementTypes", "AchievementTypeId");
        b.HasData(SeedData.AchievementTypes);
    }
}

public class DisabilityTypeConfiguration : IEntityTypeConfiguration<DisabilityType>
{
    public void Configure(EntityTypeBuilder<DisabilityType> b)
    {
        b.ConfigureMasterData("DisabilityTypes", "DisabilityTypeId");
        b.HasData(SeedData.DisabilityTypes);
    }
}

public class CommunicationTopicConfiguration : IEntityTypeConfiguration<CommunicationTopic>
{
    public void Configure(EntityTypeBuilder<CommunicationTopic> b)
    {
        b.ConfigureMasterData("CommunicationTopics", "CommunicationTopicId");
        b.HasData(SeedData.CommunicationTopics);
    }
}

public class CommunicationChannelConfiguration : IEntityTypeConfiguration<CommunicationChannel>
{
    public void Configure(EntityTypeBuilder<CommunicationChannel> b)
    {
        b.ConfigureMasterData("CommunicationChannels", "CommunicationChannelId");
        b.HasData(SeedData.CommunicationChannels);
    }
}

public class RoleConfiguration : IEntityTypeConfiguration<Role>
{
    public void Configure(EntityTypeBuilder<Role> b)
    {
        b.ConfigureMasterData("Roles", "RoleId");
        b.HasData(SeedData.Roles);
    }
}
