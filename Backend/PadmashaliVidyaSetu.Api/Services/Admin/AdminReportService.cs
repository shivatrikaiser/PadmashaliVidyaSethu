using Microsoft.EntityFrameworkCore;
using PadmashaliVidyaSetu.Api.Common;
using PadmashaliVidyaSetu.Api.Data;
using PadmashaliVidyaSetu.Api.DTOs;
using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Entities.Members;

namespace PadmashaliVidyaSetu.Api.Services.Admin;

public interface IAdminReportService
{
    Task<AdminSummaryDto> GetSummaryAsync(CancellationToken ct);
}

/// <summary>Headline numbers for the admin dashboard. Counts cover active members unless stated otherwise.</summary>
public sealed class AdminReportService(AppDbContext db, TimeProvider clock) : IAdminReportService
{
    /// <summary>Five slices at most, so the pie stays readable; college-level stages are combined. ‑ = non-breaking hyphen.</summary>
    private static readonly (string Label, string[] Stages)[] StudentStages =
    [
        ("Pre‑primary (LKG/UKG)", [EducationStages.PrePrimary]),
        ("Primary (1‑7)", [EducationStages.Primary]),
        ("High school (8‑10)", [EducationStages.HighSchool]),
        ("PUC", [EducationStages.PreUniversity]),
        ("College & other", [EducationStages.Vocational, EducationStages.UnderGraduate, EducationStages.PostGraduate,
            EducationStages.Professional, EducationStages.Other]),
    ];

    private static readonly (string Label, int From, int To)[] AgeGroups =
        [("5-9", 5, 9), ("10-14", 10, 14), ("15-17", 15, 17), ("18-22", 18, 22), ("23-30", 23, 30), ("31+", 31, int.MaxValue)];

    public async Task<AdminSummaryDto> GetSummaryAsync(CancellationToken ct)
    {
        var active = db.Members.AsNoTracking().Where(m => m.IsActive);
        var now = clock.GetUtcNow().UtcDateTime;
        var today = clock.TodayInIndia();

        var activeCount = await active.CountAsync(ct);
        var inactiveCount = await db.Members.CountAsync(m => !m.IsActive, ct);
        var accounts = await db.Accounts.CountAsync(ct);
        var last30 = await active.CountAsync(m => m.RegistrationCompletedDate >= now.AddDays(-30), ct);

        var byTemple = await active
            .GroupBy(m => new { m.Temple.Name, m.Temple.DisplayOrder })
            .Select(g => new { g.Key.Name, g.Key.DisplayOrder, Count = g.Count() })
            .OrderBy(x => x.DisplayOrder).ThenBy(x => x.Name)
            .Select(x => new CountItem(x.Name, x.Count))
            .ToListAsync(ct);
        var byStatus = await active
            .GroupBy(m => new { m.MemberStatus.Name, m.MemberStatus.DisplayOrder })
            .Select(g => new { g.Key.Name, g.Key.DisplayOrder, Count = g.Count() })
            .OrderBy(x => x.DisplayOrder).ThenBy(x => x.Name)
            .Select(x => new CountItem(x.Name, x.Count))
            .ToListAsync(ct);
        var byGender = await active
            .GroupBy(m => new { m.Gender.Name, m.Gender.DisplayOrder })
            .Select(g => new { g.Key.Name, g.Key.DisplayOrder, Count = g.Count() })
            .OrderBy(x => x.DisplayOrder).ThenBy(x => x.Name)
            .Select(x => new CountItem(x.Name, x.Count))
            .ToListAsync(ct);

        var byOrganisation = await active
            .GroupBy(m => new { m.Organisation.Name, m.Organisation.DisplayOrder })
            .Select(g => new { g.Key.Name, g.Key.DisplayOrder, Count = g.Count() })
            .OrderBy(x => x.DisplayOrder).ThenBy(x => x.Name)
            .Select(x => new CountItem(x.Name, x.Count))
            .ToListAsync(ct);

        var stageCounts = await active
            .Where(m => m.Class != null)
            .GroupBy(m => m.Class!.Stage)
            .Select(g => new { Stage = g.Key, Count = g.Count() })
            .ToListAsync(ct);
        var studentsByStage = StudentStages
            .Select(s => new CountItem(s.Label, stageCounts.Where(c => s.Stages.Contains(c.Stage)).Sum(c => c.Count)))
            .ToList();

        var byDistrict = await active
            .SelectMany(m => m.Addresses.Where(a => a.AddressType == AddressTypes.Permanent))
            // Members living outside India are counted under their country.
            .GroupBy(a => a.District != null ? a.District.Name : a.Country.Name)
            .Select(g => new { Name = g.Key, Count = g.Count() })
            .OrderByDescending(x => x.Count).ThenBy(x => x.Name)
            .Take(15)
            .Select(x => new CountItem(x.Name, x.Count))
            .ToListAsync(ct);

        var birthDates = await active.Select(m => m.DateOfBirth).ToListAsync(ct);
        var ages = birthDates.Select(d => AgeCalculator.AgeOn(d, today)).ToList();
        var byAge = AgeGroups.Select(g => new CountItem(g.Label, ages.Count(a => a >= g.From && a <= g.To))).ToList();

        var firstMonth = new DateTime(now.Year, now.Month, 1, 0, 0, 0, DateTimeKind.Utc).AddMonths(-11);
        var registered = await db.Members.AsNoTracking()
            .Where(m => m.RegistrationCompletedDate >= firstMonth)
            .GroupBy(m => new { m.RegistrationCompletedDate.Year, m.RegistrationCompletedDate.Month })
            .Select(g => new { g.Key.Year, g.Key.Month, Count = g.Count() })
            .ToListAsync(ct);
        var byMonth = Enumerable.Range(0, 12).Select(i =>
        {
            var month = firstMonth.AddMonths(i);
            var count = registered.FirstOrDefault(r => r.Year == month.Year && r.Month == month.Month)?.Count ?? 0;
            return new CountItem(month.ToString("yyyy-MM"), count);
        }).ToList();

        return new AdminSummaryDto(activeCount, inactiveCount, accounts, last30, byTemple, byStatus, byGender,
            byOrganisation, studentsByStage, byAge, byDistrict, byMonth);
    }
}
