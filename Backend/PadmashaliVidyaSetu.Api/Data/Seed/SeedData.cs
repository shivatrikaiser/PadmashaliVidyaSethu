using PadmashaliVidyaSetu.Api.Entities.Accounts;
using PadmashaliVidyaSetu.Api.Entities.Common;
using PadmashaliVidyaSetu.Api.Entities.Locations;
using PadmashaliVidyaSetu.Api.Entities.MasterData;
using PadmashaliVidyaSetu.Api.Entities.Members;

namespace PadmashaliVidyaSetu.Api.Data.Seed;

/// <summary>
/// Initial master data, applied through EF Core migrations (HasData).
/// Administrators may rename / reorder / deactivate rows later; application logic only relies on <c>Code</c>.
///
/// IMPORTANT: Temple names are placeholders. The real 16 temple names must be supplied by the
/// Padmashali Vidyavardhaka Sangha (see Docs/MasterData.md for how to update them).
/// </summary>
public static class SeedData
{
    public static readonly DateTime SeedDate = new(2026, 10, 6, 0, 0, 0, DateTimeKind.Utc);
    public const string SeedUser = "seed";

    private static T M<T>(int id, string code, string name, int? order = null) where T : MasterDataEntity, new() => new()
    {
        Id = id,
        Code = code,
        Name = name,
        DisplayOrder = order ?? id * 10,
        IsActive = true,
        CreatedDate = SeedDate,
        CreatedBy = SeedUser,
    };

    private static T[] List<T>(params (string Code, string Name)[] items) where T : MasterDataEntity, new() =>
        items.Select((x, i) => M<T>(i + 1, x.Code, x.Name)).ToArray();

    // ---------------------------------------------------------------- Temples (PLACEHOLDERS)
    public static Temple[] Temples =>
        Enumerable.Range(1, 16)
            .Select(i => M<Temple>(i, i.ToString("00"), $"Temple {i:00} (Placeholder - update name)"))
            .ToArray();

    public static TempleRegistrationSequence[] TempleSequences =>
        Enumerable.Range(1, 16).Select(i => new TempleRegistrationSequence { TempleId = i, LastSequenceNumber = 0 }).ToArray();

    public static Organisation[] Organisations => List<Organisation>(
        ("DK", "DK District"),
        ("MUMBAI", "Mumbai"),
        ("BANGALORE", "Bangalore"),
        ("DUBAI", "Dubai"),
        ("SHIMOGA", "Shimoga"),
        (MasterCodes.OrganisationNone, "Not Linked to Any Organisation"));

    public static Gender[] Genders => List<Gender>(
        ("MALE", "Male"),
        ("FEMALE", "Female"),
        ("OTHER", "Other / Prefer not to say"));

    public static MemberStatus[] MemberStatuses => List<MemberStatus>(
        (MasterCodes.StatusStudent, "Student"),
        (MasterCodes.StatusWorking, "Working"),
        (MasterCodes.StatusUnemployed, "Unemployed"));

    public static SchoolClass[] Classes
    {
        get
        {
            (string Code, string Name, string Stage)[] items =
            [
                ("LKG", "LKG", EducationStages.PrePrimary),
                ("UKG", "UKG", EducationStages.PrePrimary),
                ("CLASS_1", "Class 1", EducationStages.Primary),
                ("CLASS_2", "Class 2", EducationStages.Primary),
                ("CLASS_3", "Class 3", EducationStages.Primary),
                ("CLASS_4", "Class 4", EducationStages.Primary),
                ("CLASS_5", "Class 5", EducationStages.Primary),
                ("CLASS_6", "Class 6", EducationStages.Primary),
                ("CLASS_7", "Class 7", EducationStages.Primary),
                ("CLASS_8", "Class 8", EducationStages.HighSchool),
                ("CLASS_9", "Class 9", EducationStages.HighSchool),
                ("CLASS_10", "Class 10", EducationStages.HighSchool),
                ("PUC_1", "PUC 1", EducationStages.PreUniversity),
                ("PUC_2", "PUC 2", EducationStages.PreUniversity),
                ("ITI", "ITI", EducationStages.Vocational),
                ("DIPLOMA", "Diploma", EducationStages.Vocational),
                ("UG", "Undergraduate", EducationStages.UnderGraduate),
                ("PG", "Postgraduate", EducationStages.PostGraduate),
                ("PROFESSIONAL", "Professional Course", EducationStages.Professional),
                ("OTHER", "Other", EducationStages.Other),
            ];
            return items.Select((x, i) =>
            {
                var c = M<SchoolClass>(i + 1, x.Code, x.Name);
                c.Stage = x.Stage;
                return c;
            }).ToArray();
        }
    }

    public static EducationLevel[] EducationLevels => List<EducationLevel>(
        ("BELOW_10", "Below Class 10"),
        ("SSLC", "Class 10 / SSLC"),
        ("PUC", "PUC / Class 12"),
        ("ITI", "ITI"),
        ("DIPLOMA", "Diploma"),
        ("UG", "Undergraduate Degree"),
        ("PG", "Postgraduate Degree"),
        ("DOCTORATE", "Doctorate (PhD)"),
        ("PROFESSIONAL", "Professional Qualification (CA, CS, etc.)"),
        ("OTHER", "Other"));

    public static Course[] Courses => List<Course>(
        ("BE_BTECH", "B.E. / B.Tech"), ("MBBS", "MBBS"), ("BDS", "BDS"), ("BAMS_BHMS", "BAMS / BHMS"),
        ("BSC_NURSING", "B.Sc Nursing"), ("BPHARM", "B.Pharm"), ("BSC", "B.Sc"), ("BCOM", "B.Com"),
        ("BA", "B.A."), ("BBA", "BBA"), ("BCA", "BCA"), ("LLB", "LLB"), ("BED", "B.Ed"),
        ("ME_MTECH", "M.E. / M.Tech"), ("MSC", "M.Sc"), ("MCOM", "M.Com"), ("MA", "M.A."), ("MBA", "MBA"),
        ("MCA", "MCA"), ("MD_MS", "MD / MS"), ("CA", "Chartered Accountancy (CA)"), ("CS", "Company Secretary (CS)"),
        ("CMA", "Cost and Management Accountancy (CMA)"), ("DIPLOMA_ENGG", "Diploma in Engineering"),
        ("ITI_TRADE", "ITI Trade"), ("PHD", "PhD"), ("OTHER", "Other"));

    public static Branch[] Branches => List<Branch>(
        ("CSE", "Computer Science"), ("ISE", "Information Science / IT"), ("AIDS", "Artificial Intelligence & Data Science"),
        ("ECE", "Electronics & Communication"), ("EEE", "Electrical & Electronics"), ("MECH", "Mechanical"),
        ("CIVIL", "Civil"), ("CHEM", "Chemical"), ("BIOTECH", "Biotechnology"), ("AERO", "Aeronautical"),
        ("PHYSICS", "Physics"), ("CHEMISTRY", "Chemistry"), ("MATHS", "Mathematics"), ("BIOLOGY", "Biology"),
        ("ACCOUNTING", "Accounting & Finance"), ("ECONOMICS", "Economics"), ("MARKETING", "Marketing"),
        ("HR", "Human Resources"), ("ENGLISH", "English"), ("KANNADA", "Kannada"), ("HISTORY", "History"),
        ("PSYCHOLOGY", "Psychology"), ("OTHER", "Other"));

    public static Board[] Boards => List<Board>(
        ("KSEAB", "Karnataka State Board (KSEAB)"), ("KA_PU", "Karnataka Pre-University Board"),
        ("CBSE", "CBSE"), ("CISCE", "ICSE / ISC (CISCE)"), ("NIOS", "NIOS"), ("IB", "International Baccalaureate (IB)"),
        ("CAMBRIDGE", "Cambridge (IGCSE / A-Level)"), ("OTHER_STATE", "Other State Board"), ("OTHER", "Other"));

    public static University[] Universities => List<University>(
        ("VTU", "Visvesvaraya Technological University"), ("MANGALORE_UNIV", "Mangalore University"),
        ("RGUHS", "Rajiv Gandhi University of Health Sciences"), ("BANGALORE_UNIV", "Bangalore University"),
        ("MYSORE_UNIV", "University of Mysore"), ("KUVEMPU_UNIV", "Kuvempu University"),
        ("MAHE", "Manipal Academy of Higher Education"), ("NITTE", "Nitte (Deemed to be University)"),
        ("KSLU", "Karnataka State Law University"), ("OTHER", "Other"));

    public static CareerOption[] CareerOptions => List<CareerOption>(
        ("DOCTOR", "Doctor"), ("ENGINEER", "Engineer"), ("CA", "CA"), ("LAWYER", "Lawyer"), ("TEACHER", "Teacher"),
        ("PROFESSOR", "Professor"), ("SCIENTIST", "Scientist"), ("CIVIL_SERVICES", "Civil Services"), ("KPSC", "KPSC"),
        ("BANKING", "Banking"), ("DEFENCE", "Defence"), ("POLICE", "Police"), ("IT_PROFESSIONAL", "IT Professional"),
        ("ENTREPRENEUR", "Entrepreneur"), ("RESEARCHER", "Researcher"), ("DESIGNER", "Designer"),
        ("SPORTS_PROFESSIONAL", "Sports Professional"), ("ARTIST", "Artist"), ("SKILLED_PROFESSIONAL", "Skilled Professional"),
        ("OTHER", "Other"), ("NOT_DECIDED", "Not Decided"));

    public static InterestArea[] InterestAreas => List<InterestArea>(
        ("SCIENCE", "Science"), ("MATHEMATICS", "Mathematics"), ("TECHNOLOGY", "Technology & Computers"),
        ("MEDICINE", "Medicine & Health"), ("COMMERCE", "Commerce & Business"), ("ARTS", "Arts & Humanities"),
        ("LANGUAGES", "Languages & Literature"), ("LAW", "Law & Public Service"), ("SOCIAL_SERVICE", "Social Service"),
        ("AGRICULTURE", "Agriculture & Environment"), ("SPORTS", "Sports & Fitness"), ("MUSIC_DANCE", "Music & Dance"),
        ("OTHER", "Other"));

    public static Skill[] Skills
    {
        get
        {
            (string Code, string Name, string Category)[] items =
            [
                ("PROGRAMMING", "Programming / Coding", SkillCategories.Technical),
                ("WEB_DEV", "Web Development", SkillCategories.Technical),
                ("DATA_ANALYSIS", "Data Analysis", SkillCategories.Technical),
                ("MS_OFFICE", "MS Office / Computer Basics", SkillCategories.Technical),
                ("ACCOUNTING_SW", "Accounting Software (Tally, etc.)", SkillCategories.Technical),
                ("ELECTRICAL", "Electrical Work", SkillCategories.Technical),
                ("MECHANICAL", "Mechanical / Repair Work", SkillCategories.Technical),
                ("CAD", "CAD / Design Software", SkillCategories.Technical),
                ("COMMUNICATION", "Communication", SkillCategories.General),
                ("LEADERSHIP", "Leadership", SkillCategories.General),
                ("TEAMWORK", "Teamwork", SkillCategories.General),
                ("PUBLIC_SPEAKING", "Public Speaking", SkillCategories.General),
                ("PROBLEM_SOLVING", "Problem Solving", SkillCategories.General),
                ("TIME_MANAGEMENT", "Time Management", SkillCategories.General),
                ("ENGLISH_SPEAKING", "Spoken English", SkillCategories.General),
                ("DRAWING_PAINTING", "Drawing / Painting", SkillCategories.Creative),
                ("MUSIC", "Music (Vocal / Instrument)", SkillCategories.Creative),
                ("DANCE", "Dance", SkillCategories.Creative),
                ("CREATIVE_WRITING", "Creative Writing", SkillCategories.Creative),
                ("PHOTOGRAPHY", "Photography", SkillCategories.Creative),
                ("VIDEO_EDITING", "Video Editing", SkillCategories.Creative),
                ("CRAFTS", "Arts & Crafts", SkillCategories.Creative),
                ("WEAVING", "Weaving / Textile Craft", SkillCategories.Creative),
            ];
            return items.Select((x, i) =>
            {
                var s = M<Skill>(i + 1, x.Code, x.Name);
                s.Category = x.Category;
                return s;
            }).ToArray();
        }
    }

    public static Sport[] Sports => List<Sport>(
        ("CRICKET", "Cricket"), ("FOOTBALL", "Football"), ("VOLLEYBALL", "Volleyball"), ("BADMINTON", "Badminton"),
        ("ATHLETICS", "Athletics"), ("BASKETBALL", "Basketball"), ("SWIMMING", "Swimming"), ("CHESS", "Chess"),
        ("KABADDI", "Kabaddi"), ("OTHER", "Other"));

    public static Hobby[] Hobbies => List<Hobby>(
        ("READING", "Reading"), ("MUSIC", "Music"), ("SINGING", "Singing"), ("DRAWING", "Drawing"),
        ("PHOTOGRAPHY", "Photography"), ("GARDENING", "Gardening"), ("WRITING", "Writing"), ("TRAVELLING", "Travelling"),
        ("COOKING", "Cooking"), ("GAMING", "Gaming"), ("OTHER", "Other"));

    public static CompetitiveExam[] CompetitiveExams => List<CompetitiveExam>(
        ("JEE", "JEE"), ("NEET", "NEET"), ("KCET", "KCET"), ("CLAT", "CLAT"), ("CA", "CA"), ("CMA", "CMA"),
        ("CS", "CS"), ("UPSC", "UPSC"), ("KPSC", "KPSC"), ("SSC", "SSC"), ("BANKING", "Banking"),
        ("RAILWAYS", "Railways"), ("DEFENCE", "Defence"), ("GATE", "GATE"), ("CAT", "CAT"), ("UGC_NET", "UGC NET"),
        ("OTHER", "Other"));

    public static AchievementType[] AchievementTypes => List<AchievementType>(
        ("ACADEMIC_RANK", "Academic Rank"), ("INSTITUTION_RANK", "School/College Rank"), ("DISTRICT_RANK", "District Rank"),
        ("STATE_RANK", "State Rank"), ("NATIONAL_RANK", "National Rank"), ("OLYMPIAD", "Olympiad Achievement"),
        ("SCHOLARSHIP", "Scholarship"), ("ACADEMIC_AWARD", "Academic Award"), ("RESEARCH", "Research Achievement"),
        ("PUBLICATION", "Paper/Publication"), ("COMPETITION", "Competition Achievement"), ("OTHER", "Other"));

    public static DisabilityType[] DisabilityTypes => List<DisabilityType>(
        ("VISUAL", "Visual Impairment"), ("HEARING", "Hearing Impairment"),
        ("SPEECH_LANGUAGE", "Speech/Language Impairment"), ("PHYSICAL_MOBILITY", "Physical/Mobility Impairment"),
        ("INTELLECTUAL", "Intellectual Disability"), ("SPECIFIC_LEARNING", "Specific Learning Disability"),
        ("MULTIPLE", "Multiple Disabilities"), (MasterCodes.DisabilityOther, "Other"));

    public static CommunicationTopic[] CommunicationTopics => List<CommunicationTopic>(
        ("SCHOLARSHIPS", "Scholarships"), ("EDUCATION_PROGRAMS", "Education Programs"), ("CAREER_GUIDANCE", "Career Guidance"),
        ("COMPETITIVE_EXAMS", "Competitive Exams"), ("JOBS", "Jobs"), ("INTERNSHIPS", "Internships"), ("TRAINING", "Training"),
        ("COMPETITIONS", "Competitions"), ("PVS_ACTIVITIES", "PVS Activities"), ("COMMUNITY_ANNOUNCEMENTS", "Community Announcements"));

    public static CommunicationChannel[] CommunicationChannels => List<CommunicationChannel>(
        ("WHATSAPP", "WhatsApp"), ("SMS", "SMS"), ("EMAIL", "Email"), ("APP", "App Notifications"));

    public static Role[] Roles => List<Role>(
        (RoleCodes.Member, "Member"), (RoleCodes.Admin, "Admin"), (RoleCodes.SuperAdmin, "Super Admin"),
        (RoleCodes.DistrictCoordinator, "District Coordinator"), (RoleCodes.TempleCoordinator, "Temple Coordinator"),
        (RoleCodes.EducationCoordinator, "Education Coordinator"), (RoleCodes.CareerCoordinator, "Career Coordinator"),
        (RoleCodes.EmploymentCoordinator, "Employment Coordinator"), (RoleCodes.ScholarshipCoordinator, "Scholarship Coordinator"),
        (RoleCodes.CommunicationManager, "Communication Manager"));

    // ---------------------------------------------------------------- Locations
    public const int IndiaCountryId = 1;
    public const int KarnatakaStateId = 11;

    public static Country[] Countries => List<Country>(
        (MasterCodes.CountryIndia, "India"), ("AE", "United Arab Emirates"), ("OM", "Oman"), ("QA", "Qatar"),
        ("SA", "Saudi Arabia"), ("KW", "Kuwait"), ("BH", "Bahrain"), ("US", "United States"), ("GB", "United Kingdom"),
        ("CA", "Canada"), ("AU", "Australia"), ("SG", "Singapore"), ("DE", "Germany"), ("NZ", "New Zealand"));

    public static State[] States
    {
        get
        {
            // 28 states followed by 8 union territories. Karnataka must remain Id 11 (KarnatakaStateId).
            (string Code, string Name, string? Postal)[] items =
            [
                ("AP", "Andhra Pradesh", null), ("AR", "Arunachal Pradesh", null), ("AS", "Assam", null),
                ("BR", "Bihar", null), ("CG", "Chhattisgarh", "Chattisgarh"), ("GA", "Goa", null), ("GJ", "Gujarat", null),
                ("HR", "Haryana", null), ("HP", "Himachal Pradesh", null), ("JH", "Jharkhand", null),
                ("KA", "Karnataka", null), ("KL", "Kerala", null), ("MP", "Madhya Pradesh", null),
                ("MH", "Maharashtra", null), ("MN", "Manipur", null), ("ML", "Meghalaya", null), ("MZ", "Mizoram", null),
                ("NL", "Nagaland", null), ("OD", "Odisha", "Orissa"), ("PB", "Punjab", null), ("RJ", "Rajasthan", null),
                ("SK", "Sikkim", null), ("TN", "Tamil Nadu", null), ("TS", "Telangana", null), ("TR", "Tripura", null),
                ("UP", "Uttar Pradesh", null), ("UK", "Uttarakhand", "Uttaranchal"), ("WB", "West Bengal", null),
                ("AN", "Andaman and Nicobar Islands", null), ("CH", "Chandigarh", null),
                ("DH", "Dadra and Nagar Haveli and Daman and Diu", null), ("DL", "Delhi", null),
                ("JK", "Jammu and Kashmir", null), ("LA", "Ladakh", null), ("LD", "Lakshadweep", null),
                ("PY", "Puducherry", "Pondicherry"),
            ];
            return items.Select((x, i) =>
            {
                var s = M<State>(i + 1, $"IN-{x.Code}", x.Name);
                s.CountryId = IndiaCountryId;
                s.PostalName = x.Postal;
                return s;
            }).ToArray();
        }
    }

    // Karnataka's 31 districts. PostalName = legacy spelling used by India Post where known.
    private static readonly (string Code, string Name, string? Postal)[] KarnatakaDistricts =
    [
        ("BGK", "Bagalkote", "Bagalkot"), ("BLR", "Ballari", "Bellary"), ("BGM", "Belagavi", "Belgaum"),
        ("BRR", "Bengaluru Rural", "Bangalore Rural"), ("BLU", "Bengaluru Urban", "Bangalore"), ("BDR", "Bidar", null),
        ("CMJ", "Chamarajanagar", "Chamrajnagar"), ("CBP", "Chikkaballapur", null), ("CKM", "Chikkamagaluru", "Chikmagalur"),
        ("CTA", "Chitradurga", null), ("DK", "Dakshina Kannada", null), ("DVG", "Davanagere", "Davangere"),
        ("DWD", "Dharwad", null), ("GDG", "Gadag", null), ("HSN", "Hassan", null), ("HVR", "Haveri", null),
        ("KLB", "Kalaburagi", "Gulbarga"), ("KDG", "Kodagu", null), ("KLR", "Kolar", null), ("KPL", "Koppal", null),
        ("MDY", "Mandya", null), ("MYS", "Mysuru", "Mysore"), ("RCR", "Raichur", null), ("RMN", "Ramanagara", "Ramanagar"),
        ("SMG", "Shivamogga", "Shimoga"), ("TMK", "Tumakuru", "Tumkur"), ("UDP", "Udupi", null), ("UK", "Uttara Kannada", null),
        ("VJN", "Vijayanagara", null), ("VJP", "Vijayapura", "Bijapur"), ("YDG", "Yadgir", null),
    ];

    public static District[] Districts => KarnatakaDistricts.Select((x, i) =>
    {
        var d = M<District>(i + 1, $"KA-{x.Code}", x.Name);
        d.StateId = KarnatakaStateId;
        d.PostalName = x.Postal;
        d.Source = LocationSources.Seed;
        return d;
    }).ToArray();

    private static int DistrictId(string code) =>
        Array.FindIndex(KarnatakaDistricts, d => d.Code == code) + 1;

    // Initial taluks for the districts with the largest Padmashali presence. Other taluks are learned
    // from PIN-code lookups or added by administrators. To be verified by the Sangha.
    public static Taluk[] Taluks
    {
        get
        {
            (string District, string Name, string? Postal)[] items =
            [
                ("DK", "Mangaluru", "Mangalore"), ("DK", "Bantwal", null), ("DK", "Puttur", null), ("DK", "Belthangady", null),
                ("DK", "Sullia", null), ("DK", "Kadaba", null), ("DK", "Moodbidri", "Mudbidri"), ("DK", "Ullal", null),
                ("DK", "Mulki", null),
                ("UDP", "Udupi", null), ("UDP", "Kundapura", "Kundapur"), ("UDP", "Karkala", null), ("UDP", "Kapu", "Kaup"),
                ("UDP", "Brahmavar", null), ("UDP", "Byndoor", null), ("UDP", "Hebri", null),
                ("SMG", "Shivamogga", "Shimoga"), ("SMG", "Bhadravati", null), ("SMG", "Sagar", "Sagara"),
                ("SMG", "Shikaripura", null), ("SMG", "Soraba", null), ("SMG", "Thirthahalli", null), ("SMG", "Hosanagara", null),
                ("BLU", "Bengaluru North", "Bangalore North"), ("BLU", "Bengaluru South", "Bangalore South"),
                ("BLU", "Bengaluru East", "Bangalore East"), ("BLU", "Anekal", null), ("BLU", "Yelahanka", null),
                ("UK", "Karwar", null), ("UK", "Ankola", null), ("UK", "Kumta", null), ("UK", "Honnavar", null),
                ("UK", "Bhatkal", null), ("UK", "Sirsi", null), ("UK", "Siddapur", null), ("UK", "Yellapur", null),
                ("UK", "Mundgod", null), ("UK", "Haliyal", null), ("UK", "Joida", null), ("UK", "Dandeli", null),
            ];
            return items.Select((x, i) =>
            {
                var t = M<Taluk>(i + 1, $"KA-{x.District}-{Slug(x.Name)}", x.Name);
                t.DistrictId = DistrictId(x.District);
                t.PostalName = x.Postal;
                t.Source = LocationSources.Seed;
                return t;
            }).ToArray();
        }
    }

    private static string Slug(string value) =>
        new string(value.ToUpperInvariant().Where(char.IsLetterOrDigit).ToArray());
}
