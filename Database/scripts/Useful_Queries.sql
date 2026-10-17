-- Handy read-only queries for administrators / developers.

-- Members per temple, status and class
SELECT t.TempleName, s.Name AS Status, c.Name AS Class, COUNT(*) AS Members
FROM dbo.PVS_Members m
JOIN dbo.PVS_Temples t ON t.TempleId = m.TempleId
JOIN dbo.PVS_MemberStatuses s ON s.MemberStatusId = m.MemberStatusId
LEFT JOIN dbo.PVS_Classes c ON c.ClassId = m.ClassId
WHERE m.IsActive = 1
GROUP BY t.TempleName, s.Name, c.Name
ORDER BY t.TempleName, s.Name, c.Name;

-- "Other" values typed by members, awaiting a proper master record (create it, then re-map the member)
SELECT 'Highest Education' AS List, m.RegistrationId, m.HighestEducationLevelOtherText AS OtherText, m.CreatedDate
FROM dbo.PVS_Members m WHERE m.HighestEducationLevelOtherText IS NOT NULL
UNION ALL
SELECT 'Disability Type', RegistrationId, OtherText, CreatedDate FROM dbo.PVS_MemberDisabilities WHERE OtherText IS NOT NULL
UNION ALL
SELECT 'Skill', RegistrationId, OtherText, CreatedDate FROM dbo.PVS_MemberSkills WHERE OtherText IS NOT NULL
UNION ALL
SELECT 'Interest Area', RegistrationId, OtherText, CreatedDate FROM dbo.PVS_MemberInterestAreas WHERE OtherText IS NOT NULL
UNION ALL
SELECT 'Sport', RegistrationId, OtherText, CreatedDate FROM dbo.PVS_MemberSports WHERE OtherText IS NOT NULL
UNION ALL
SELECT 'Hobby', RegistrationId, OtherText, CreatedDate FROM dbo.PVS_MemberHobbies WHERE OtherText IS NOT NULL
UNION ALL
SELECT 'Career Option', RegistrationId, OtherText, CreatedDate FROM dbo.PVS_MemberCareerAspirations WHERE OtherText IS NOT NULL
UNION ALL
SELECT 'Competitive Exam', RegistrationId, OtherText, CreatedDate FROM dbo.PVS_MemberCompetitiveExams WHERE OtherText IS NOT NULL
UNION ALL
SELECT 'Education Level', RegistrationId, EducationLevelOtherText, CreatedDate FROM dbo.PVS_MemberEducation WHERE EducationLevelOtherText IS NOT NULL
UNION ALL
SELECT 'Course', RegistrationId, CourseOtherText, CreatedDate FROM dbo.PVS_MemberEducation WHERE CourseOtherText IS NOT NULL
UNION ALL
SELECT 'Branch', RegistrationId, BranchOtherText, CreatedDate FROM dbo.PVS_MemberEducation WHERE BranchOtherText IS NOT NULL
UNION ALL
SELECT 'Board', RegistrationId, BoardOtherText, CreatedDate FROM dbo.PVS_MemberEducation WHERE BoardOtherText IS NOT NULL
UNION ALL
SELECT 'Achievement Type', RegistrationId, AchievementTypeOtherText, CreatedDate FROM dbo.PVS_AcademicAchievements WHERE AchievementTypeOtherText IS NOT NULL
ORDER BY List, OtherText;

-- Districts / taluks learned automatically from PIN-code lookups or typed by members (review & merge)
SELECT 'District' AS Kind, d.Name, s.Name AS Parent, d.Source FROM dbo.PVS_Districts d JOIN dbo.PVS_States s ON s.StateId = d.StateId WHERE d.Source <> 'Seed'
UNION ALL
SELECT 'Taluk', t.Name, d.Name, t.Source FROM dbo.PVS_Taluks t JOIN dbo.PVS_Districts d ON d.DistrictId = t.DistrictId WHERE t.Source <> 'Seed'
ORDER BY Kind, Parent, Name;

-- Next Registration number per temple
SELECT t.TempleCode, t.TempleName, s.LastSequenceNumber
FROM dbo.PVS_TempleRegistrationSequences s JOIN dbo.PVS_Temples t ON t.TempleId = s.TempleId ORDER BY t.TempleCode;
