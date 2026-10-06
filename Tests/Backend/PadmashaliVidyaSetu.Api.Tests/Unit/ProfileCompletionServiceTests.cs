using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Services.Members;

namespace PadmashaliVidyaSetu.Api.Tests.Unit;

public sealed class ProfileCompletionServiceTests
{
    private readonly ProfileCompletionService _service = new();

    [Fact]
    public void Student_EmploymentNotApplicable_BasicComplete()
    {
        var result = _service.Calculate(new ProfileFacts("PVS-01-0001", MasterCodes.StatusStudent, EducationStages.PreUniversity, 17));

        Assert.Equal("Complete", result.Sections.Single(s => s.Key == "basic").Status);
        Assert.Equal("NotApplicable", result.Sections.Single(s => s.Key == "employment").Status);
        Assert.Equal("NotStarted", result.Sections.Single(s => s.Key == "competitiveExams").Status);
    }

    [Fact]
    public void YoungChild_HigherEducationAndExamsNotApplicable_CareerUsesInterestWording()
    {
        var result = _service.Calculate(new ProfileFacts("PVS-01-0002", MasterCodes.StatusStudent, EducationStages.Primary, 8));

        Assert.Equal("NotApplicable", result.Sections.Single(s => s.Key == "higherEducation").Status);
        Assert.Equal("NotApplicable", result.Sections.Single(s => s.Key == "competitiveExams").Status);
        Assert.Equal("Areas of Career Interest", result.Sections.Single(s => s.Key == "career").Title);
    }

    [Theory]
    [InlineData(MasterCodes.StatusWorking)]
    [InlineData(MasterCodes.StatusUnemployed)]
    public void NonStudent_EmploymentApplicable(string status)
    {
        var result = _service.Calculate(new ProfileFacts("PVS-01-0003", status, null, 28));
        Assert.Equal("NotStarted", result.Sections.Single(s => s.Key == "employment").Status);
    }

    [Fact]
    public void Overall_IsAverageOfApplicableSections()
    {
        var result = _service.Calculate(new ProfileFacts("PVS-01-0004", MasterCodes.StatusStudent, EducationStages.Primary, 8));

        var applicable = result.Sections.Where(s => s.Status != "NotApplicable").ToList();
        Assert.Equal((int)Math.Round(applicable.Average(s => s.Percent)), result.OverallPercent);
    }

    [Fact]
    public void UnbuiltModules_AreMarkedUnavailable_NotFaked()
    {
        var result = _service.Calculate(new ProfileFacts("PVS-01-0005", MasterCodes.StatusWorking, null, 30));

        Assert.All(result.Sections.Where(s => s.Key != "basic"), s =>
        {
            Assert.False(s.IsAvailable);
            Assert.Equal(0, s.Percent);
        });
    }
}
