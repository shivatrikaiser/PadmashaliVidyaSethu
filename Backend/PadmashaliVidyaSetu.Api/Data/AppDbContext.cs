using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Authentication;
using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.Compliance;
using PadmashaliVidyaSetu.Api.Entities.Locations;
using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Entities.Members;
using PadmashaliVidyaSetu.Api.Entities.Settings;

namespace PadmashaliVidyaSetu.Api.Data;

public class AppDbContext(
    DbContextOptions<AppDbContext> options,
    ICurrentUserService currentUser,
    TimeProvider clock) : DbContext(options)
{
    // Master data
    public DbSet<Temple> Temples => Set<Temple>();
    public DbSet<Organisation> Organisations => Set<Organisation>();
    public DbSet<Gender> Genders => Set<Gender>();
    public DbSet<MemberStatus> MemberStatuses => Set<MemberStatus>();
    public DbSet<SchoolClass> Classes => Set<SchoolClass>();
    public DbSet<EducationLevel> EducationLevels => Set<EducationLevel>();
    public DbSet<Course> Courses => Set<Course>();
    public DbSet<Branch> Branches => Set<Branch>();
    public DbSet<Board> Boards => Set<Board>();
    public DbSet<University> Universities => Set<University>();
    public DbSet<CareerOption> CareerOptions => Set<CareerOption>();
    public DbSet<InterestArea> InterestAreas => Set<InterestArea>();
    public DbSet<Skill> Skills => Set<Skill>();
    public DbSet<Sport> Sports => Set<Sport>();
    public DbSet<Hobby> Hobbies => Set<Hobby>();
    public DbSet<CompetitiveExam> CompetitiveExams => Set<CompetitiveExam>();
    public DbSet<AchievementType> AchievementTypes => Set<AchievementType>();
    public DbSet<DisabilityType> DisabilityTypes => Set<DisabilityType>();
    public DbSet<CommunicationTopic> CommunicationTopics => Set<CommunicationTopic>();
    public DbSet<CommunicationChannel> CommunicationChannels => Set<CommunicationChannel>();

    // Locations
    public DbSet<Country> Countries => Set<Country>();
    public DbSet<State> States => Set<State>();
    public DbSet<District> Districts => Set<District>();
    public DbSet<Taluk> Taluks => Set<Taluk>();
    public DbSet<City> Cities => Set<City>();

    // Accounts & security
    public DbSet<Account> Accounts => Set<Account>();
    public DbSet<Role> Roles => Set<Role>();
    public DbSet<AccountRole> AccountRoles => Set<AccountRole>();
    public DbSet<RefreshToken> RefreshTokens => Set<RefreshToken>();
    public DbSet<PhoneVerificationChallenge> PhoneVerificationChallenges => Set<PhoneVerificationChallenge>();

    // Members
    public DbSet<Member> Members => Set<Member>();
    public DbSet<MemberAddress> MemberAddresses => Set<MemberAddress>();
    public DbSet<MemberDisability> MemberDisabilities => Set<MemberDisability>();
    public DbSet<TempleRegistrationSequence> TempleRegistrationSequences => Set<TempleRegistrationSequence>();

    // Member profile (list choices with "Other" text)
    public DbSet<MemberEducation> MemberEducation => Set<MemberEducation>();
    public DbSet<MemberSkill> MemberSkills => Set<MemberSkill>();
    public DbSet<MemberInterestArea> MemberInterestAreas => Set<MemberInterestArea>();
    public DbSet<MemberSport> MemberSports => Set<MemberSport>();
    public DbSet<MemberHobby> MemberHobbies => Set<MemberHobby>();
    public DbSet<MemberCareerAspiration> MemberCareerAspirations => Set<MemberCareerAspiration>();
    public DbSet<MemberCompetitiveExam> MemberCompetitiveExams => Set<MemberCompetitiveExam>();
    public DbSet<AcademicAchievement> AcademicAchievements => Set<AcademicAchievement>();

    // Compliance
    public DbSet<ConsentRecord> ConsentRecords => Set<ConsentRecord>();
    public DbSet<AuditLog> AuditLogs => Set<AuditLog>();

    // Settings
    public DbSet<AppBranding> AppBranding => Set<AppBranding>();
    public DbSet<FooterSponsor> FooterSponsors => Set<FooterSponsor>();
    public DbSet<AppVersion> AppVersions => Set<AppVersion>();
    public DbSet<PushNotification> PushNotifications => Set<PushNotification>();

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(AppDbContext).Assembly);
        modelBuilder.ApplyPvsNaming();
    }

    public override int SaveChanges(bool acceptAllChangesOnSuccess)
    {
        StampAuditFields();
        return base.SaveChanges(acceptAllChangesOnSuccess);
    }

    public override Task<int> SaveChangesAsync(bool acceptAllChangesOnSuccess, CancellationToken cancellationToken = default)
    {
        StampAuditFields();
        return base.SaveChangesAsync(acceptAllChangesOnSuccess, cancellationToken);
    }

    private void StampAuditFields()
    {
        var now = clock.GetUtcNow().UtcDateTime;
        var actor = currentUser.AuditName;

        foreach (var entry in ChangeTracker.Entries<AuditableEntity>())
        {
            switch (entry.State)
            {
                case EntityState.Added:
                    entry.Entity.CreatedDate = now;
                    entry.Entity.CreatedBy ??= actor;
                    break;
                case EntityState.Modified:
                    entry.Property(e => e.CreatedDate).IsModified = false;
                    entry.Property(e => e.CreatedBy).IsModified = false;
                    entry.Entity.ModifiedDate = now;
                    entry.Entity.ModifiedBy = actor;
                    break;
            }
        }
    }
}
