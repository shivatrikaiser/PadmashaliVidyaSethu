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

-- Disability types added by members ("Other - please specify") awaiting review
SELECT DisabilityTypeId, Name, Code, CreatedDate FROM dbo.PVS_DisabilityTypes WHERE IsUserSubmitted = 1 ORDER BY CreatedDate DESC;

-- Districts / taluks learned automatically from PIN-code lookups or typed by members (review & merge)
SELECT 'District' AS Kind, d.Name, s.Name AS Parent, d.Source FROM dbo.PVS_Districts d JOIN dbo.PVS_States s ON s.StateId = d.StateId WHERE d.Source <> 'Seed'
UNION ALL
SELECT 'Taluk', t.Name, d.Name, t.Source FROM dbo.PVS_Taluks t JOIN dbo.PVS_Districts d ON d.DistrictId = t.DistrictId WHERE t.Source <> 'Seed'
ORDER BY Kind, Parent, Name;

-- Next Registration number per temple
SELECT t.TempleCode, t.TempleName, s.LastSequenceNumber
FROM dbo.PVS_TempleRegistrationSequences s JOIN dbo.PVS_Temples t ON t.TempleId = s.TempleId ORDER BY t.TempleCode;
