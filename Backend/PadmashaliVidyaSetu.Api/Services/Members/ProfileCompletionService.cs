using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.MasterData;

namespace PadmashaliVidyaSetu.Api.Services.Members;

/// <summary>Inputs the completion rules need about a member, loaded once by the caller.</summary>
public sealed record ProfileFacts(string RegistrationId, string StatusCode, string? ClassStage, int Age);

public interface IProfileCompletionService
{
    ProfileCompletionDto Calculate(ProfileFacts facts);
}

/// <summary>
/// Computes the per-section completion shown on the dashboard. Each section decides whether it applies to the
/// member (e.g. Employment only for Working / Unemployed). Overall % is the average of applicable sections.
///
/// Sections whose module has not been built yet are reported with <c>IsAvailable = false</c> and 0% so the
/// dashboard never shows fabricated progress. As each later phase lands, its section reads real data here.
/// </summary>
public sealed class ProfileCompletionService : IProfileCompletionService
{
    public static class Statuses
    {
        public const string Complete = "Complete";
        public const string InProgress = "InProgress";
        public const string NotStarted = "NotStarted";
        public const string NotApplicable = "NotApplicable";
    }

    private static readonly string[] SeniorStages =
    [
        EducationStages.HighSchool, EducationStages.PreUniversity, EducationStages.Vocational,
        EducationStages.UnderGraduate, EducationStages.PostGraduate, EducationStages.Professional, EducationStages.Other,
    ];

    public ProfileCompletionDto Calculate(ProfileFacts facts)
    {
        var isStudent = facts.StatusCode == MasterCodes.StatusStudent;
        // Competitive exams / higher education planning are not relevant to young school children.
        var isSeniorLearner = !isStudent || (facts.ClassStage is not null && SeniorStages.Contains(facts.ClassStage));

        var sections = new List<ProfileSectionDto>
        {
            Section("basic", "Basic Information", 100, available: true),
            Section("education", "Education", 0),
            Section("academic", "Academic Profile", 0),
            Section("interests", "Interests & Skills", 0),
            Section("career", facts.Age < 13 ? "Areas of Career Interest" : "Career Aspirations", 0),
            Section("competitiveExams", "Competitive Exams", 0, applicable: isSeniorLearner),
            Section("higherEducation", "Higher Education", 0, applicable: isSeniorLearner),
            Section("employment", "Employment", 0, applicable: !isStudent),
            Section("communication", "Communication Preferences", 0),
        };

        var applicable = sections.Where(s => s.Status != Statuses.NotApplicable).ToList();
        var overall = applicable.Count == 0 ? 0 : (int)Math.Round(applicable.Average(s => s.Percent));
        return new ProfileCompletionDto(facts.RegistrationId, overall, sections);
    }

    private static ProfileSectionDto Section(string key, string title, int percent, bool applicable = true, bool available = false)
    {
        if (!applicable) return new ProfileSectionDto(key, title, Statuses.NotApplicable, 0, available);
        var status = percent >= 100 ? Statuses.Complete : percent > 0 ? Statuses.InProgress : Statuses.NotStarted;
        return new ProfileSectionDto(key, title, status, Math.Clamp(percent, 0, 100), available);
    }
}
