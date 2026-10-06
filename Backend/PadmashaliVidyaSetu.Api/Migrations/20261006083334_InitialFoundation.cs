using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class InitialFoundation : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "Accounts",
                columns: table => new
                {
                    AccountId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    MobileNumber = table.Column<string>(type: "varchar(16)", unicode: false, maxLength: 16, nullable: false),
                    MobileVerifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    LastLoginDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Accounts", x => x.AccountId);
                    table.CheckConstraint("CK_Accounts_MobileNumber", "[MobileNumber] LIKE '+[1-9]%'");
                });

            migrationBuilder.CreateTable(
                name: "AchievementTypes",
                columns: table => new
                {
                    AchievementTypeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AchievementTypes", x => x.AchievementTypeId);
                });

            migrationBuilder.CreateTable(
                name: "AuditLogs",
                columns: table => new
                {
                    AuditLogId = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AccountId = table.Column<int>(type: "int", nullable: true),
                    Action = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    EntityName = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: true),
                    EntityKey = table.Column<string>(type: "nvarchar(50)", maxLength: 50, nullable: true),
                    Details = table.Column<string>(type: "nvarchar(1000)", maxLength: 1000, nullable: true),
                    IpAddress = table.Column<string>(type: "varchar(45)", unicode: false, maxLength: 45, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AuditLogs", x => x.AuditLogId);
                });

            migrationBuilder.CreateTable(
                name: "Boards",
                columns: table => new
                {
                    BoardId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Boards", x => x.BoardId);
                });

            migrationBuilder.CreateTable(
                name: "Branches",
                columns: table => new
                {
                    BranchId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Branches", x => x.BranchId);
                });

            migrationBuilder.CreateTable(
                name: "CareerOptions",
                columns: table => new
                {
                    CareerOptionId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CareerOptions", x => x.CareerOptionId);
                });

            migrationBuilder.CreateTable(
                name: "Classes",
                columns: table => new
                {
                    ClassId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Stage = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Classes", x => x.ClassId);
                    table.CheckConstraint("CK_Classes_Stage", "[Stage] IN ('PrePrimary', 'Primary', 'HighSchool', 'PreUniversity', 'Vocational', 'UnderGraduate', 'PostGraduate', 'Professional', 'Other')");
                });

            migrationBuilder.CreateTable(
                name: "CommunicationChannels",
                columns: table => new
                {
                    CommunicationChannelId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CommunicationChannels", x => x.CommunicationChannelId);
                });

            migrationBuilder.CreateTable(
                name: "CommunicationTopics",
                columns: table => new
                {
                    CommunicationTopicId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CommunicationTopics", x => x.CommunicationTopicId);
                });

            migrationBuilder.CreateTable(
                name: "CompetitiveExams",
                columns: table => new
                {
                    CompetitiveExamId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_CompetitiveExams", x => x.CompetitiveExamId);
                });

            migrationBuilder.CreateTable(
                name: "Countries",
                columns: table => new
                {
                    CountryId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Countries", x => x.CountryId);
                });

            migrationBuilder.CreateTable(
                name: "Courses",
                columns: table => new
                {
                    CourseId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Courses", x => x.CourseId);
                });

            migrationBuilder.CreateTable(
                name: "DisabilityTypes",
                columns: table => new
                {
                    DisabilityTypeId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    IsUserSubmitted = table.Column<bool>(type: "bit", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_DisabilityTypes", x => x.DisabilityTypeId);
                });

            migrationBuilder.CreateTable(
                name: "EducationLevels",
                columns: table => new
                {
                    EducationLevelId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EducationLevels", x => x.EducationLevelId);
                });

            migrationBuilder.CreateTable(
                name: "Genders",
                columns: table => new
                {
                    GenderId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Genders", x => x.GenderId);
                });

            migrationBuilder.CreateTable(
                name: "Hobbies",
                columns: table => new
                {
                    HobbyId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Hobbies", x => x.HobbyId);
                });

            migrationBuilder.CreateTable(
                name: "InterestAreas",
                columns: table => new
                {
                    InterestAreaId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_InterestAreas", x => x.InterestAreaId);
                });

            migrationBuilder.CreateTable(
                name: "MemberStatuses",
                columns: table => new
                {
                    MemberStatusId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MemberStatuses", x => x.MemberStatusId);
                });

            migrationBuilder.CreateTable(
                name: "Organisations",
                columns: table => new
                {
                    OrganisationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    OrganisationName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    OrganisationCode = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Organisations", x => x.OrganisationId);
                });

            migrationBuilder.CreateTable(
                name: "PhoneVerificationChallenges",
                columns: table => new
                {
                    ChallengeId = table.Column<Guid>(type: "uniqueidentifier", nullable: false),
                    MobileNumber = table.Column<string>(type: "varchar(16)", unicode: false, maxLength: 16, nullable: false),
                    CodeHash = table.Column<string>(type: "char(64)", unicode: false, fixedLength: true, maxLength: 64, nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    ExpiresDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    FailedAttemptCount = table.Column<int>(type: "int", nullable: false),
                    VerifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    RequestIp = table.Column<string>(type: "varchar(45)", unicode: false, maxLength: 45, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_PhoneVerificationChallenges", x => x.ChallengeId);
                });

            migrationBuilder.CreateTable(
                name: "Roles",
                columns: table => new
                {
                    RoleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Roles", x => x.RoleId);
                });

            migrationBuilder.CreateTable(
                name: "Skills",
                columns: table => new
                {
                    SkillId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Category = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Skills", x => x.SkillId);
                    table.CheckConstraint("CK_Skills_Category", "[Category] IN ('Technical', 'General', 'Creative')");
                });

            migrationBuilder.CreateTable(
                name: "Sports",
                columns: table => new
                {
                    SportId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Sports", x => x.SportId);
                });

            migrationBuilder.CreateTable(
                name: "Temples",
                columns: table => new
                {
                    TempleId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    TempleName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    TempleCode = table.Column<string>(type: "varchar(2)", unicode: false, maxLength: 2, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Temples", x => x.TempleId);
                    table.CheckConstraint("CK_Temples_TempleCode", "[TempleCode] LIKE '[0-9][0-9]'");
                });

            migrationBuilder.CreateTable(
                name: "Universities",
                columns: table => new
                {
                    UniversityId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Universities", x => x.UniversityId);
                });

            migrationBuilder.CreateTable(
                name: "RefreshTokens",
                columns: table => new
                {
                    RefreshTokenId = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AccountId = table.Column<int>(type: "int", nullable: false),
                    TokenHash = table.Column<string>(type: "char(64)", unicode: false, fixedLength: true, maxLength: 64, nullable: false),
                    ExpiresDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    CreatedByIp = table.Column<string>(type: "varchar(45)", unicode: false, maxLength: 45, nullable: true),
                    RevokedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    ReplacedByTokenHash = table.Column<string>(type: "char(64)", unicode: false, fixedLength: true, maxLength: 64, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_RefreshTokens", x => x.RefreshTokenId);
                    table.ForeignKey(
                        name: "FK_RefreshTokens_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "AccountId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "States",
                columns: table => new
                {
                    StateId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    CountryId = table.Column<int>(type: "int", nullable: false),
                    PostalName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_States", x => x.StateId);
                    table.ForeignKey(
                        name: "FK_States_Countries_CountryId",
                        column: x => x.CountryId,
                        principalTable: "Countries",
                        principalColumn: "CountryId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "AccountRoles",
                columns: table => new
                {
                    AccountId = table.Column<int>(type: "int", nullable: false),
                    RoleId = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_AccountRoles", x => new { x.AccountId, x.RoleId });
                    table.ForeignKey(
                        name: "FK_AccountRoles_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "AccountId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_AccountRoles_Roles_RoleId",
                        column: x => x.RoleId,
                        principalTable: "Roles",
                        principalColumn: "RoleId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Members",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    AccountId = table.Column<int>(type: "int", nullable: false),
                    FullName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    FatherName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    MotherName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    DateOfBirth = table.Column<DateOnly>(type: "date", nullable: false),
                    GenderId = table.Column<int>(type: "int", nullable: false),
                    TempleId = table.Column<int>(type: "int", nullable: false),
                    MemberStatusId = table.Column<int>(type: "int", nullable: false),
                    ClassId = table.Column<int>(type: "int", nullable: true),
                    HighestEducationLevelId = table.Column<int>(type: "int", nullable: true),
                    OrganisationId = table.Column<int>(type: "int", nullable: false),
                    IsCurrentAddressSameAsPermanent = table.Column<bool>(type: "bit", nullable: false),
                    IsDisabled = table.Column<bool>(type: "bit", nullable: false),
                    RegistrationCompletedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Members", x => x.RegistrationId);
                    table.CheckConstraint("CK_Members_ClassOrHighestEducation", "[ClassId] IS NULL OR [HighestEducationLevelId] IS NULL");
                    table.CheckConstraint("CK_Members_RegistrationId", "[RegistrationId] LIKE 'PVS-[0-9][0-9]-[0-9][0-9][0-9][0-9]'");
                    table.ForeignKey(
                        name: "FK_Members_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "AccountId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_Classes_ClassId",
                        column: x => x.ClassId,
                        principalTable: "Classes",
                        principalColumn: "ClassId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_EducationLevels_HighestEducationLevelId",
                        column: x => x.HighestEducationLevelId,
                        principalTable: "EducationLevels",
                        principalColumn: "EducationLevelId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_Genders_GenderId",
                        column: x => x.GenderId,
                        principalTable: "Genders",
                        principalColumn: "GenderId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_MemberStatuses_MemberStatusId",
                        column: x => x.MemberStatusId,
                        principalTable: "MemberStatuses",
                        principalColumn: "MemberStatusId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_Organisations_OrganisationId",
                        column: x => x.OrganisationId,
                        principalTable: "Organisations",
                        principalColumn: "OrganisationId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Members_Temples_TempleId",
                        column: x => x.TempleId,
                        principalTable: "Temples",
                        principalColumn: "TempleId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "TempleRegistrationSequences",
                columns: table => new
                {
                    TempleId = table.Column<int>(type: "int", nullable: false),
                    LastSequenceNumber = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_TempleRegistrationSequences", x => x.TempleId);
                    table.CheckConstraint("CK_TempleRegistrationSequences_Range", "[LastSequenceNumber] BETWEEN 0 AND 9999");
                    table.ForeignKey(
                        name: "FK_TempleRegistrationSequences_Temples_TempleId",
                        column: x => x.TempleId,
                        principalTable: "Temples",
                        principalColumn: "TempleId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Districts",
                columns: table => new
                {
                    DistrictId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    StateId = table.Column<int>(type: "int", nullable: false),
                    PostalName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    Source = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Districts", x => x.DistrictId);
                    table.ForeignKey(
                        name: "FK_Districts_States_StateId",
                        column: x => x.StateId,
                        principalTable: "States",
                        principalColumn: "StateId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "ConsentRecords",
                columns: table => new
                {
                    ConsentRecordId = table.Column<long>(type: "bigint", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    AccountId = table.Column<int>(type: "int", nullable: false),
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: true),
                    ConsentType = table.Column<string>(type: "varchar(40)", unicode: false, maxLength: 40, nullable: false),
                    PolicyVersion = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    IsGranted = table.Column<bool>(type: "bit", nullable: false),
                    RecordedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    IpAddress = table.Column<string>(type: "varchar(45)", unicode: false, maxLength: 45, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_ConsentRecords", x => x.ConsentRecordId);
                    table.ForeignKey(
                        name: "FK_ConsentRecords_Accounts_AccountId",
                        column: x => x.AccountId,
                        principalTable: "Accounts",
                        principalColumn: "AccountId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_ConsentRecords_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MemberDisabilities",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    DisabilityTypeId = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MemberDisabilities", x => new { x.RegistrationId, x.DisabilityTypeId });
                    table.ForeignKey(
                        name: "FK_MemberDisabilities_DisabilityTypes_DisabilityTypeId",
                        column: x => x.DisabilityTypeId,
                        principalTable: "DisabilityTypes",
                        principalColumn: "DisabilityTypeId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MemberDisabilities_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "Taluks",
                columns: table => new
                {
                    TalukId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    DistrictId = table.Column<int>(type: "int", nullable: false),
                    PostalName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    Source = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Taluks", x => x.TalukId);
                    table.ForeignKey(
                        name: "FK_Taluks_Districts_DistrictId",
                        column: x => x.DistrictId,
                        principalTable: "Districts",
                        principalColumn: "DistrictId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "Cities",
                columns: table => new
                {
                    CityId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    PinCode = table.Column<string>(type: "char(6)", unicode: false, fixedLength: true, maxLength: 6, nullable: false),
                    DistrictId = table.Column<int>(type: "int", nullable: false),
                    TalukId = table.Column<int>(type: "int", nullable: true),
                    Source = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Code = table.Column<string>(type: "varchar(60)", unicode: false, maxLength: 60, nullable: false),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_Cities", x => x.CityId);
                    table.CheckConstraint("CK_Cities_PinCode", "[PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'");
                    table.ForeignKey(
                        name: "FK_Cities_Districts_DistrictId",
                        column: x => x.DistrictId,
                        principalTable: "Districts",
                        principalColumn: "DistrictId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_Cities_Taluks_TalukId",
                        column: x => x.TalukId,
                        principalTable: "Taluks",
                        principalColumn: "TalukId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "MemberAddresses",
                columns: table => new
                {
                    MemberAddressId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    AddressType = table.Column<string>(type: "varchar(10)", unicode: false, maxLength: 10, nullable: false),
                    AddressLine1 = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: false),
                    AddressLine2 = table.Column<string>(type: "nvarchar(200)", maxLength: 200, nullable: true),
                    PinCode = table.Column<string>(type: "char(6)", unicode: false, fixedLength: true, maxLength: 6, nullable: false),
                    CityVillageName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    CityId = table.Column<int>(type: "int", nullable: true),
                    TalukId = table.Column<int>(type: "int", nullable: false),
                    DistrictId = table.Column<int>(type: "int", nullable: false),
                    StateId = table.Column<int>(type: "int", nullable: false),
                    CountryId = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_MemberAddresses", x => x.MemberAddressId);
                    table.CheckConstraint("CK_MemberAddresses_AddressType", "[AddressType] IN ('Permanent', 'Current')");
                    table.CheckConstraint("CK_MemberAddresses_PinCode", "[PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'");
                    table.ForeignKey(
                        name: "FK_MemberAddresses_Cities_CityId",
                        column: x => x.CityId,
                        principalTable: "Cities",
                        principalColumn: "CityId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MemberAddresses_Countries_CountryId",
                        column: x => x.CountryId,
                        principalTable: "Countries",
                        principalColumn: "CountryId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MemberAddresses_Districts_DistrictId",
                        column: x => x.DistrictId,
                        principalTable: "Districts",
                        principalColumn: "DistrictId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MemberAddresses_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_MemberAddresses_States_StateId",
                        column: x => x.StateId,
                        principalTable: "States",
                        principalColumn: "StateId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "FK_MemberAddresses_Taluks_TalukId",
                        column: x => x.TalukId,
                        principalTable: "Taluks",
                        principalColumn: "TalukId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.InsertData(
                table: "AchievementTypes",
                columns: new[] { "AchievementTypeId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "ACADEMIC_RANK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Academic Rank" },
                    { 2, "INSTITUTION_RANK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "School/College Rank" },
                    { 3, "DISTRICT_RANK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "District Rank" },
                    { 4, "STATE_RANK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "State Rank" },
                    { 5, "NATIONAL_RANK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "National Rank" },
                    { 6, "OLYMPIAD", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Olympiad Achievement" },
                    { 7, "SCHOLARSHIP", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Scholarship" },
                    { 8, "ACADEMIC_AWARD", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Academic Award" },
                    { 9, "RESEARCH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Research Achievement" },
                    { 10, "PUBLICATION", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Paper/Publication" },
                    { 11, "COMPETITION", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Competition Achievement" },
                    { 12, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "Boards",
                columns: new[] { "BoardId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "KSEAB", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Karnataka State Board (KSEAB)" },
                    { 2, "KA_PU", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Karnataka Pre-University Board" },
                    { 3, "CBSE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "CBSE" },
                    { 4, "CISCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "ICSE / ISC (CISCE)" },
                    { 5, "NIOS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "NIOS" },
                    { 6, "IB", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "International Baccalaureate (IB)" },
                    { 7, "CAMBRIDGE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Cambridge (IGCSE / A-Level)" },
                    { 8, "OTHER_STATE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Other State Board" },
                    { 9, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "Branches",
                columns: new[] { "BranchId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "CSE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Computer Science" },
                    { 2, "ISE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Information Science / IT" },
                    { 3, "AIDS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Artificial Intelligence & Data Science" },
                    { 4, "ECE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Electronics & Communication" },
                    { 5, "EEE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Electrical & Electronics" },
                    { 6, "MECH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Mechanical" },
                    { 7, "CIVIL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Civil" },
                    { 8, "CHEM", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Chemical" },
                    { 9, "BIOTECH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Biotechnology" },
                    { 10, "AERO", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Aeronautical" },
                    { 11, "PHYSICS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Physics" },
                    { 12, "CHEMISTRY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Chemistry" },
                    { 13, "MATHS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Mathematics" },
                    { 14, "BIOLOGY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "Biology" },
                    { 15, "ACCOUNTING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "Accounting & Finance" },
                    { 16, "ECONOMICS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "Economics" },
                    { 17, "MARKETING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "Marketing" },
                    { 18, "HR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, true, null, null, "Human Resources" },
                    { 19, "ENGLISH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, true, null, null, "English" },
                    { 20, "KANNADA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, true, null, null, "Kannada" },
                    { 21, "HISTORY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 210, true, null, null, "History" },
                    { 22, "PSYCHOLOGY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 220, true, null, null, "Psychology" },
                    { 23, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 230, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "CareerOptions",
                columns: new[] { "CareerOptionId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "DOCTOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Doctor" },
                    { 2, "ENGINEER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Engineer" },
                    { 3, "CA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "CA" },
                    { 4, "LAWYER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Lawyer" },
                    { 5, "TEACHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Teacher" },
                    { 6, "PROFESSOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Professor" },
                    { 7, "SCIENTIST", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Scientist" },
                    { 8, "CIVIL_SERVICES", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Civil Services" },
                    { 9, "KPSC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "KPSC" },
                    { 10, "BANKING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Banking" },
                    { 11, "DEFENCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Defence" },
                    { 12, "POLICE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Police" },
                    { 13, "IT_PROFESSIONAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "IT Professional" },
                    { 14, "ENTREPRENEUR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "Entrepreneur" },
                    { 15, "RESEARCHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "Researcher" },
                    { 16, "DESIGNER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "Designer" },
                    { 17, "SPORTS_PROFESSIONAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "Sports Professional" },
                    { 18, "ARTIST", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, true, null, null, "Artist" },
                    { 19, "SKILLED_PROFESSIONAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, true, null, null, "Skilled Professional" },
                    { 20, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, true, null, null, "Other" },
                    { 21, "NOT_DECIDED", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 210, true, null, null, "Not Decided" }
                });

            migrationBuilder.InsertData(
                table: "Classes",
                columns: new[] { "ClassId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name", "Stage" },
                values: new object[,]
                {
                    { 1, "LKG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "LKG", "PrePrimary" },
                    { 2, "UKG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "UKG", "PrePrimary" },
                    { 3, "CLASS_1", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Class 1", "Primary" },
                    { 4, "CLASS_2", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Class 2", "Primary" },
                    { 5, "CLASS_3", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Class 3", "Primary" },
                    { 6, "CLASS_4", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Class 4", "Primary" },
                    { 7, "CLASS_5", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Class 5", "Primary" },
                    { 8, "CLASS_6", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Class 6", "Primary" },
                    { 9, "CLASS_7", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Class 7", "Primary" },
                    { 10, "CLASS_8", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Class 8", "HighSchool" },
                    { 11, "CLASS_9", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Class 9", "HighSchool" },
                    { 12, "CLASS_10", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Class 10", "HighSchool" },
                    { 13, "PUC_1", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "PUC 1", "PreUniversity" },
                    { 14, "PUC_2", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "PUC 2", "PreUniversity" },
                    { 15, "ITI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "ITI", "Vocational" },
                    { 16, "DIPLOMA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "Diploma", "Vocational" },
                    { 17, "UG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "Undergraduate", "UnderGraduate" },
                    { 18, "PG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, true, null, null, "Postgraduate", "PostGraduate" },
                    { 19, "PROFESSIONAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, true, null, null, "Professional Course", "Professional" },
                    { 20, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, true, null, null, "Other", "Other" }
                });

            migrationBuilder.InsertData(
                table: "CommunicationChannels",
                columns: new[] { "CommunicationChannelId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "WHATSAPP", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "WhatsApp" },
                    { 2, "SMS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "SMS" },
                    { 3, "EMAIL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Email" },
                    { 4, "APP", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "App Notifications" }
                });

            migrationBuilder.InsertData(
                table: "CommunicationTopics",
                columns: new[] { "CommunicationTopicId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "SCHOLARSHIPS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Scholarships" },
                    { 2, "EDUCATION_PROGRAMS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Education Programs" },
                    { 3, "CAREER_GUIDANCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Career Guidance" },
                    { 4, "COMPETITIVE_EXAMS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Competitive Exams" },
                    { 5, "JOBS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Jobs" },
                    { 6, "INTERNSHIPS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Internships" },
                    { 7, "TRAINING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Training" },
                    { 8, "COMPETITIONS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Competitions" },
                    { 9, "PVS_ACTIVITIES", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "PVS Activities" },
                    { 10, "COMMUNITY_ANNOUNCEMENTS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Community Announcements" }
                });

            migrationBuilder.InsertData(
                table: "CompetitiveExams",
                columns: new[] { "CompetitiveExamId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "JEE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "JEE" },
                    { 2, "NEET", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "NEET" },
                    { 3, "KCET", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "KCET" },
                    { 4, "CLAT", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "CLAT" },
                    { 5, "CA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "CA" },
                    { 6, "CMA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "CMA" },
                    { 7, "CS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "CS" },
                    { 8, "UPSC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "UPSC" },
                    { 9, "KPSC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "KPSC" },
                    { 10, "SSC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "SSC" },
                    { 11, "BANKING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Banking" },
                    { 12, "RAILWAYS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Railways" },
                    { 13, "DEFENCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Defence" },
                    { 14, "GATE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "GATE" },
                    { 15, "CAT", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "CAT" },
                    { 16, "UGC_NET", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "UGC NET" },
                    { 17, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "Countries",
                columns: new[] { "CountryId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "IN", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "India" },
                    { 2, "AE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "United Arab Emirates" },
                    { 3, "OM", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Oman" },
                    { 4, "QA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Qatar" },
                    { 5, "SA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Saudi Arabia" },
                    { 6, "KW", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Kuwait" },
                    { 7, "BH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Bahrain" },
                    { 8, "US", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "United States" },
                    { 9, "GB", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "United Kingdom" },
                    { 10, "CA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Canada" },
                    { 11, "AU", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Australia" },
                    { 12, "SG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Singapore" },
                    { 13, "DE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Germany" },
                    { 14, "NZ", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "New Zealand" }
                });

            migrationBuilder.InsertData(
                table: "Courses",
                columns: new[] { "CourseId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "BE_BTECH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "B.E. / B.Tech" },
                    { 2, "MBBS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "MBBS" },
                    { 3, "BDS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "BDS" },
                    { 4, "BAMS_BHMS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "BAMS / BHMS" },
                    { 5, "BSC_NURSING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "B.Sc Nursing" },
                    { 6, "BPHARM", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "B.Pharm" },
                    { 7, "BSC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "B.Sc" },
                    { 8, "BCOM", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "B.Com" },
                    { 9, "BA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "B.A." },
                    { 10, "BBA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "BBA" },
                    { 11, "BCA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "BCA" },
                    { 12, "LLB", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "LLB" },
                    { 13, "BED", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "B.Ed" },
                    { 14, "ME_MTECH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "M.E. / M.Tech" },
                    { 15, "MSC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "M.Sc" },
                    { 16, "MCOM", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "M.Com" },
                    { 17, "MA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "M.A." },
                    { 18, "MBA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, true, null, null, "MBA" },
                    { 19, "MCA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, true, null, null, "MCA" },
                    { 20, "MD_MS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, true, null, null, "MD / MS" },
                    { 21, "CA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 210, true, null, null, "Chartered Accountancy (CA)" },
                    { 22, "CS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 220, true, null, null, "Company Secretary (CS)" },
                    { 23, "CMA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 230, true, null, null, "Cost and Management Accountancy (CMA)" },
                    { 24, "DIPLOMA_ENGG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 240, true, null, null, "Diploma in Engineering" },
                    { 25, "ITI_TRADE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 250, true, null, null, "ITI Trade" },
                    { 26, "PHD", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 260, true, null, null, "PhD" },
                    { 27, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 270, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "DisabilityTypes",
                columns: new[] { "DisabilityTypeId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "IsUserSubmitted", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "VISUAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, false, null, null, "Visual Impairment" },
                    { 2, "HEARING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, false, null, null, "Hearing Impairment" },
                    { 3, "SPEECH_LANGUAGE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, false, null, null, "Speech/Language Impairment" },
                    { 4, "PHYSICAL_MOBILITY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, false, null, null, "Physical/Mobility Impairment" },
                    { 5, "INTELLECTUAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, false, null, null, "Intellectual Disability" },
                    { 6, "SPECIFIC_LEARNING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, false, null, null, "Specific Learning Disability" },
                    { 7, "MULTIPLE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, false, null, null, "Multiple Disabilities" },
                    { 8, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, false, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "EducationLevels",
                columns: new[] { "EducationLevelId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "BELOW_10", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Below Class 10" },
                    { 2, "SSLC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Class 10 / SSLC" },
                    { 3, "PUC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "PUC / Class 12" },
                    { 4, "ITI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "ITI" },
                    { 5, "DIPLOMA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Diploma" },
                    { 6, "UG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Undergraduate Degree" },
                    { 7, "PG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Postgraduate Degree" },
                    { 8, "DOCTORATE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Doctorate (PhD)" },
                    { 9, "PROFESSIONAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Professional Qualification (CA, CS, etc.)" },
                    { 10, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "Genders",
                columns: new[] { "GenderId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "MALE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Male" },
                    { 2, "FEMALE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Female" },
                    { 3, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Other / Prefer not to say" }
                });

            migrationBuilder.InsertData(
                table: "Hobbies",
                columns: new[] { "HobbyId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "READING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Reading" },
                    { 2, "MUSIC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Music" },
                    { 3, "SINGING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Singing" },
                    { 4, "DRAWING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Drawing" },
                    { 5, "PHOTOGRAPHY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Photography" },
                    { 6, "GARDENING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Gardening" },
                    { 7, "WRITING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Writing" },
                    { 8, "TRAVELLING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Travelling" },
                    { 9, "COOKING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Cooking" },
                    { 10, "GAMING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Gaming" },
                    { 11, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "InterestAreas",
                columns: new[] { "InterestAreaId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "SCIENCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Science" },
                    { 2, "MATHEMATICS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Mathematics" },
                    { 3, "TECHNOLOGY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Technology & Computers" },
                    { 4, "MEDICINE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Medicine & Health" },
                    { 5, "COMMERCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Commerce & Business" },
                    { 6, "ARTS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Arts & Humanities" },
                    { 7, "LANGUAGES", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Languages & Literature" },
                    { 8, "LAW", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Law & Public Service" },
                    { 9, "SOCIAL_SERVICE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Social Service" },
                    { 10, "AGRICULTURE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Agriculture & Environment" },
                    { 11, "SPORTS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Sports & Fitness" },
                    { 12, "MUSIC_DANCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Music & Dance" },
                    { 13, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "MemberStatuses",
                columns: new[] { "MemberStatusId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "STUDENT", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Student" },
                    { 2, "WORKING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Working" },
                    { 3, "UNEMPLOYED", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Unemployed" }
                });

            migrationBuilder.InsertData(
                table: "Organisations",
                columns: new[] { "OrganisationId", "OrganisationCode", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "OrganisationName" },
                values: new object[,]
                {
                    { 1, "DK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "DK District" },
                    { 2, "MUMBAI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Mumbai" },
                    { 3, "BANGALORE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Bangalore" },
                    { 4, "DUBAI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Dubai" },
                    { 5, "SHIMOGA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Shimoga" },
                    { 6, "NONE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Not Linked to Any Organisation" }
                });

            migrationBuilder.InsertData(
                table: "Roles",
                columns: new[] { "RoleId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "MEMBER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Member" },
                    { 2, "ADMIN", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Admin" },
                    { 3, "SUPER_ADMIN", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Super Admin" },
                    { 4, "DISTRICT_COORDINATOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "District Coordinator" },
                    { 5, "TEMPLE_COORDINATOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Temple Coordinator" },
                    { 6, "EDUCATION_COORDINATOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Education Coordinator" },
                    { 7, "CAREER_COORDINATOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Career Coordinator" },
                    { 8, "EMPLOYMENT_COORDINATOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Employment Coordinator" },
                    { 9, "SCHOLARSHIP_COORDINATOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Scholarship Coordinator" },
                    { 10, "COMMUNICATION_MANAGER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Communication Manager" }
                });

            migrationBuilder.InsertData(
                table: "Skills",
                columns: new[] { "SkillId", "Category", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "Technical", "PROGRAMMING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Programming / Coding" },
                    { 2, "Technical", "WEB_DEV", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Web Development" },
                    { 3, "Technical", "DATA_ANALYSIS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Data Analysis" },
                    { 4, "Technical", "MS_OFFICE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "MS Office / Computer Basics" },
                    { 5, "Technical", "ACCOUNTING_SW", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Accounting Software (Tally, etc.)" },
                    { 6, "Technical", "ELECTRICAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Electrical Work" },
                    { 7, "Technical", "MECHANICAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Mechanical / Repair Work" },
                    { 8, "Technical", "CAD", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "CAD / Design Software" },
                    { 9, "General", "COMMUNICATION", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Communication" },
                    { 10, "General", "LEADERSHIP", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Leadership" },
                    { 11, "General", "TEAMWORK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Teamwork" },
                    { 12, "General", "PUBLIC_SPEAKING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Public Speaking" },
                    { 13, "General", "PROBLEM_SOLVING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Problem Solving" },
                    { 14, "General", "TIME_MANAGEMENT", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "Time Management" },
                    { 15, "General", "ENGLISH_SPEAKING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "Spoken English" },
                    { 16, "Creative", "DRAWING_PAINTING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "Drawing / Painting" },
                    { 17, "Creative", "MUSIC", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "Music (Vocal / Instrument)" },
                    { 18, "Creative", "DANCE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, true, null, null, "Dance" },
                    { 19, "Creative", "CREATIVE_WRITING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, true, null, null, "Creative Writing" },
                    { 20, "Creative", "PHOTOGRAPHY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, true, null, null, "Photography" },
                    { 21, "Creative", "VIDEO_EDITING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 210, true, null, null, "Video Editing" },
                    { 22, "Creative", "CRAFTS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 220, true, null, null, "Arts & Crafts" },
                    { 23, "Creative", "WEAVING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 230, true, null, null, "Weaving / Textile Craft" }
                });

            migrationBuilder.InsertData(
                table: "Sports",
                columns: new[] { "SportId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "CRICKET", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Cricket" },
                    { 2, "FOOTBALL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Football" },
                    { 3, "VOLLEYBALL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Volleyball" },
                    { 4, "BADMINTON", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Badminton" },
                    { 5, "ATHLETICS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Athletics" },
                    { 6, "BASKETBALL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Basketball" },
                    { 7, "SWIMMING", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Swimming" },
                    { 8, "CHESS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Chess" },
                    { 9, "KABADDI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Kabaddi" },
                    { 10, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "Temples",
                columns: new[] { "TempleId", "TempleCode", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "TempleName" },
                values: new object[,]
                {
                    { 1, "01", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Temple 01 (Placeholder - update name)" },
                    { 2, "02", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Temple 02 (Placeholder - update name)" },
                    { 3, "03", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Temple 03 (Placeholder - update name)" },
                    { 4, "04", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Temple 04 (Placeholder - update name)" },
                    { 5, "05", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Temple 05 (Placeholder - update name)" },
                    { 6, "06", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Temple 06 (Placeholder - update name)" },
                    { 7, "07", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Temple 07 (Placeholder - update name)" },
                    { 8, "08", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Temple 08 (Placeholder - update name)" },
                    { 9, "09", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Temple 09 (Placeholder - update name)" },
                    { 10, "10", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Temple 10 (Placeholder - update name)" },
                    { 11, "11", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Temple 11 (Placeholder - update name)" },
                    { 12, "12", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Temple 12 (Placeholder - update name)" },
                    { 13, "13", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Temple 13 (Placeholder - update name)" },
                    { 14, "14", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "Temple 14 (Placeholder - update name)" },
                    { 15, "15", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "Temple 15 (Placeholder - update name)" },
                    { 16, "16", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "Temple 16 (Placeholder - update name)" }
                });

            migrationBuilder.InsertData(
                table: "Universities",
                columns: new[] { "UniversityId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name" },
                values: new object[,]
                {
                    { 1, "VTU", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Visvesvaraya Technological University" },
                    { 2, "MANGALORE_UNIV", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Mangalore University" },
                    { 3, "RGUHS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Rajiv Gandhi University of Health Sciences" },
                    { 4, "BANGALORE_UNIV", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Bangalore University" },
                    { 5, "MYSORE_UNIV", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "University of Mysore" },
                    { 6, "KUVEMPU_UNIV", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Kuvempu University" },
                    { 7, "MAHE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Manipal Academy of Higher Education" },
                    { 8, "NITTE", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Nitte (Deemed to be University)" },
                    { 9, "KSLU", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Karnataka State Law University" },
                    { 10, "OTHER", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Other" }
                });

            migrationBuilder.InsertData(
                table: "States",
                columns: new[] { "StateId", "Code", "CountryId", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name", "PostalName" },
                values: new object[,]
                {
                    { 1, "IN-AP", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Andhra Pradesh", null },
                    { 2, "IN-AR", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Arunachal Pradesh", null },
                    { 3, "IN-AS", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Assam", null },
                    { 4, "IN-BR", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Bihar", null },
                    { 5, "IN-CG", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Chhattisgarh", "Chattisgarh" },
                    { 6, "IN-GA", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Goa", null },
                    { 7, "IN-GJ", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Gujarat", null },
                    { 8, "IN-HR", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Haryana", null },
                    { 9, "IN-HP", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Himachal Pradesh", null },
                    { 10, "IN-JH", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Jharkhand", null },
                    { 11, "IN-KA", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Karnataka", null },
                    { 12, "IN-KL", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Kerala", null },
                    { 13, "IN-MP", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Madhya Pradesh", null },
                    { 14, "IN-MH", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "Maharashtra", null },
                    { 15, "IN-MN", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "Manipur", null },
                    { 16, "IN-ML", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "Meghalaya", null },
                    { 17, "IN-MZ", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "Mizoram", null },
                    { 18, "IN-NL", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, true, null, null, "Nagaland", null },
                    { 19, "IN-OD", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, true, null, null, "Odisha", "Orissa" },
                    { 20, "IN-PB", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, true, null, null, "Punjab", null },
                    { 21, "IN-RJ", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 210, true, null, null, "Rajasthan", null },
                    { 22, "IN-SK", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 220, true, null, null, "Sikkim", null },
                    { 23, "IN-TN", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 230, true, null, null, "Tamil Nadu", null },
                    { 24, "IN-TS", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 240, true, null, null, "Telangana", null },
                    { 25, "IN-TR", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 250, true, null, null, "Tripura", null },
                    { 26, "IN-UP", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 260, true, null, null, "Uttar Pradesh", null },
                    { 27, "IN-UK", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 270, true, null, null, "Uttarakhand", "Uttaranchal" },
                    { 28, "IN-WB", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 280, true, null, null, "West Bengal", null },
                    { 29, "IN-AN", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 290, true, null, null, "Andaman and Nicobar Islands", null },
                    { 30, "IN-CH", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 300, true, null, null, "Chandigarh", null },
                    { 31, "IN-DH", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 310, true, null, null, "Dadra and Nagar Haveli and Daman and Diu", null },
                    { 32, "IN-DL", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 320, true, null, null, "Delhi", null },
                    { 33, "IN-JK", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 330, true, null, null, "Jammu and Kashmir", null },
                    { 34, "IN-LA", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 340, true, null, null, "Ladakh", null },
                    { 35, "IN-LD", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 350, true, null, null, "Lakshadweep", null },
                    { 36, "IN-PY", 1, "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 360, true, null, null, "Puducherry", "Pondicherry" }
                });

            migrationBuilder.InsertData(
                table: "TempleRegistrationSequences",
                columns: new[] { "TempleId", "LastSequenceNumber" },
                values: new object[,]
                {
                    { 1, 0 },
                    { 2, 0 },
                    { 3, 0 },
                    { 4, 0 },
                    { 5, 0 },
                    { 6, 0 },
                    { 7, 0 },
                    { 8, 0 },
                    { 9, 0 },
                    { 10, 0 },
                    { 11, 0 },
                    { 12, 0 },
                    { 13, 0 },
                    { 14, 0 },
                    { 15, 0 },
                    { 16, 0 }
                });

            migrationBuilder.InsertData(
                table: "Districts",
                columns: new[] { "DistrictId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "Name", "PostalName", "Source", "StateId" },
                values: new object[,]
                {
                    { 1, "KA-BGK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, true, null, null, "Bagalkote", "Bagalkot", "Seed", 11 },
                    { 2, "KA-BLR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, true, null, null, "Ballari", "Bellary", "Seed", 11 },
                    { 3, "KA-BGM", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, true, null, null, "Belagavi", "Belgaum", "Seed", 11 },
                    { 4, "KA-BRR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, true, null, null, "Bengaluru Rural", "Bangalore Rural", "Seed", 11 },
                    { 5, "KA-BLU", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, true, null, null, "Bengaluru Urban", "Bangalore", "Seed", 11 },
                    { 6, "KA-BDR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, true, null, null, "Bidar", null, "Seed", 11 },
                    { 7, "KA-CMJ", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, true, null, null, "Chamarajanagar", "Chamrajnagar", "Seed", 11 },
                    { 8, "KA-CBP", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, true, null, null, "Chikkaballapur", null, "Seed", 11 },
                    { 9, "KA-CKM", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, true, null, null, "Chikkamagaluru", "Chikmagalur", "Seed", 11 },
                    { 10, "KA-CTA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, true, null, null, "Chitradurga", null, "Seed", 11 },
                    { 11, "KA-DK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, true, null, null, "Dakshina Kannada", null, "Seed", 11 },
                    { 12, "KA-DVG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, true, null, null, "Davanagere", "Davangere", "Seed", 11 },
                    { 13, "KA-DWD", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, true, null, null, "Dharwad", null, "Seed", 11 },
                    { 14, "KA-GDG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, true, null, null, "Gadag", null, "Seed", 11 },
                    { 15, "KA-HSN", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, true, null, null, "Hassan", null, "Seed", 11 },
                    { 16, "KA-HVR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, true, null, null, "Haveri", null, "Seed", 11 },
                    { 17, "KA-KLB", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, true, null, null, "Kalaburagi", "Gulbarga", "Seed", 11 },
                    { 18, "KA-KDG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, true, null, null, "Kodagu", null, "Seed", 11 },
                    { 19, "KA-KLR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, true, null, null, "Kolar", null, "Seed", 11 },
                    { 20, "KA-KPL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, true, null, null, "Koppal", null, "Seed", 11 },
                    { 21, "KA-MDY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 210, true, null, null, "Mandya", null, "Seed", 11 },
                    { 22, "KA-MYS", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 220, true, null, null, "Mysuru", "Mysore", "Seed", 11 },
                    { 23, "KA-RCR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 230, true, null, null, "Raichur", null, "Seed", 11 },
                    { 24, "KA-RMN", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 240, true, null, null, "Ramanagara", "Ramanagar", "Seed", 11 },
                    { 25, "KA-SMG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 250, true, null, null, "Shivamogga", "Shimoga", "Seed", 11 },
                    { 26, "KA-TMK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 260, true, null, null, "Tumakuru", "Tumkur", "Seed", 11 },
                    { 27, "KA-UDP", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 270, true, null, null, "Udupi", null, "Seed", 11 },
                    { 28, "KA-UK", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 280, true, null, null, "Uttara Kannada", null, "Seed", 11 },
                    { 29, "KA-VJN", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 290, true, null, null, "Vijayanagara", null, "Seed", 11 },
                    { 30, "KA-VJP", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 300, true, null, null, "Vijayapura", "Bijapur", "Seed", 11 },
                    { 31, "KA-YDG", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 310, true, null, null, "Yadgir", null, "Seed", 11 }
                });

            migrationBuilder.InsertData(
                table: "Taluks",
                columns: new[] { "TalukId", "Code", "CreatedBy", "CreatedDate", "DisplayOrder", "DistrictId", "IsActive", "ModifiedBy", "ModifiedDate", "Name", "PostalName", "Source" },
                values: new object[,]
                {
                    { 1, "KA-DK-MANGALURU", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 10, 11, true, null, null, "Mangaluru", "Mangalore", "Seed" },
                    { 2, "KA-DK-BANTWAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 20, 11, true, null, null, "Bantwal", null, "Seed" },
                    { 3, "KA-DK-PUTTUR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 30, 11, true, null, null, "Puttur", null, "Seed" },
                    { 4, "KA-DK-BELTHANGADY", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 40, 11, true, null, null, "Belthangady", null, "Seed" },
                    { 5, "KA-DK-SULLIA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 50, 11, true, null, null, "Sullia", null, "Seed" },
                    { 6, "KA-DK-KADABA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 60, 11, true, null, null, "Kadaba", null, "Seed" },
                    { 7, "KA-DK-MOODBIDRI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 70, 11, true, null, null, "Moodbidri", "Mudbidri", "Seed" },
                    { 8, "KA-DK-ULLAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 80, 11, true, null, null, "Ullal", null, "Seed" },
                    { 9, "KA-DK-MULKI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 90, 11, true, null, null, "Mulki", null, "Seed" },
                    { 10, "KA-UDP-UDUPI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 100, 27, true, null, null, "Udupi", null, "Seed" },
                    { 11, "KA-UDP-KUNDAPURA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 110, 27, true, null, null, "Kundapura", "Kundapur", "Seed" },
                    { 12, "KA-UDP-KARKALA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 120, 27, true, null, null, "Karkala", null, "Seed" },
                    { 13, "KA-UDP-KAPU", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 130, 27, true, null, null, "Kapu", "Kaup", "Seed" },
                    { 14, "KA-UDP-BRAHMAVAR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 140, 27, true, null, null, "Brahmavar", null, "Seed" },
                    { 15, "KA-UDP-BYNDOOR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 150, 27, true, null, null, "Byndoor", null, "Seed" },
                    { 16, "KA-UDP-HEBRI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 160, 27, true, null, null, "Hebri", null, "Seed" },
                    { 17, "KA-SMG-SHIVAMOGGA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 170, 25, true, null, null, "Shivamogga", "Shimoga", "Seed" },
                    { 18, "KA-SMG-BHADRAVATI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 180, 25, true, null, null, "Bhadravati", null, "Seed" },
                    { 19, "KA-SMG-SAGAR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 190, 25, true, null, null, "Sagar", "Sagara", "Seed" },
                    { 20, "KA-SMG-SHIKARIPURA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 200, 25, true, null, null, "Shikaripura", null, "Seed" },
                    { 21, "KA-SMG-SORABA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 210, 25, true, null, null, "Soraba", null, "Seed" },
                    { 22, "KA-SMG-THIRTHAHALLI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 220, 25, true, null, null, "Thirthahalli", null, "Seed" },
                    { 23, "KA-SMG-HOSANAGARA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 230, 25, true, null, null, "Hosanagara", null, "Seed" },
                    { 24, "KA-BLU-BENGALURUNORTH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 240, 5, true, null, null, "Bengaluru North", "Bangalore North", "Seed" },
                    { 25, "KA-BLU-BENGALURUSOUTH", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 250, 5, true, null, null, "Bengaluru South", "Bangalore South", "Seed" },
                    { 26, "KA-BLU-BENGALURUEAST", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 260, 5, true, null, null, "Bengaluru East", "Bangalore East", "Seed" },
                    { 27, "KA-BLU-ANEKAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 270, 5, true, null, null, "Anekal", null, "Seed" },
                    { 28, "KA-BLU-YELAHANKA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 280, 5, true, null, null, "Yelahanka", null, "Seed" },
                    { 29, "KA-UK-KARWAR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 290, 28, true, null, null, "Karwar", null, "Seed" },
                    { 30, "KA-UK-ANKOLA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 300, 28, true, null, null, "Ankola", null, "Seed" },
                    { 31, "KA-UK-KUMTA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 310, 28, true, null, null, "Kumta", null, "Seed" },
                    { 32, "KA-UK-HONNAVAR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 320, 28, true, null, null, "Honnavar", null, "Seed" },
                    { 33, "KA-UK-BHATKAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 330, 28, true, null, null, "Bhatkal", null, "Seed" },
                    { 34, "KA-UK-SIRSI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 340, 28, true, null, null, "Sirsi", null, "Seed" },
                    { 35, "KA-UK-SIDDAPUR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 350, 28, true, null, null, "Siddapur", null, "Seed" },
                    { 36, "KA-UK-YELLAPUR", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 360, 28, true, null, null, "Yellapur", null, "Seed" },
                    { 37, "KA-UK-MUNDGOD", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 370, 28, true, null, null, "Mundgod", null, "Seed" },
                    { 38, "KA-UK-HALIYAL", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 380, 28, true, null, null, "Haliyal", null, "Seed" },
                    { 39, "KA-UK-JOIDA", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 390, 28, true, null, null, "Joida", null, "Seed" },
                    { 40, "KA-UK-DANDELI", "seed", new DateTime(2026, 10, 6, 0, 0, 0, 0, DateTimeKind.Utc), 400, 28, true, null, null, "Dandeli", null, "Seed" }
                });

            migrationBuilder.CreateIndex(
                name: "IX_AccountRoles_RoleId",
                table: "AccountRoles",
                column: "RoleId");

            migrationBuilder.CreateIndex(
                name: "IX_Accounts_MobileNumber",
                table: "Accounts",
                column: "MobileNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AchievementTypes_Code",
                table: "AchievementTypes",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AchievementTypes_IsActive_DisplayOrder",
                table: "AchievementTypes",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_AchievementTypes_Name",
                table: "AchievementTypes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_AuditLogs_AccountId_CreatedDate",
                table: "AuditLogs",
                columns: new[] { "AccountId", "CreatedDate" });

            migrationBuilder.CreateIndex(
                name: "IX_AuditLogs_CreatedDate",
                table: "AuditLogs",
                column: "CreatedDate");

            migrationBuilder.CreateIndex(
                name: "IX_Boards_Code",
                table: "Boards",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Boards_IsActive_DisplayOrder",
                table: "Boards",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Boards_Name",
                table: "Boards",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Branches_Code",
                table: "Branches",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Branches_IsActive_DisplayOrder",
                table: "Branches",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Branches_Name",
                table: "Branches",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CareerOptions_Code",
                table: "CareerOptions",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CareerOptions_IsActive_DisplayOrder",
                table: "CareerOptions",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_CareerOptions_Name",
                table: "CareerOptions",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cities_Code",
                table: "Cities",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cities_DistrictId",
                table: "Cities",
                column: "DistrictId");

            migrationBuilder.CreateIndex(
                name: "IX_Cities_IsActive_DisplayOrder",
                table: "Cities",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Cities_PinCode_Name",
                table: "Cities",
                columns: new[] { "PinCode", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Cities_TalukId",
                table: "Cities",
                column: "TalukId");

            migrationBuilder.CreateIndex(
                name: "IX_Classes_Code",
                table: "Classes",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Classes_IsActive_DisplayOrder",
                table: "Classes",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Classes_Name",
                table: "Classes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CommunicationChannels_Code",
                table: "CommunicationChannels",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CommunicationChannels_IsActive_DisplayOrder",
                table: "CommunicationChannels",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_CommunicationChannels_Name",
                table: "CommunicationChannels",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CommunicationTopics_Code",
                table: "CommunicationTopics",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CommunicationTopics_IsActive_DisplayOrder",
                table: "CommunicationTopics",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_CommunicationTopics_Name",
                table: "CommunicationTopics",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CompetitiveExams_Code",
                table: "CompetitiveExams",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_CompetitiveExams_IsActive_DisplayOrder",
                table: "CompetitiveExams",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_CompetitiveExams_Name",
                table: "CompetitiveExams",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_ConsentRecords_AccountId_ConsentType",
                table: "ConsentRecords",
                columns: new[] { "AccountId", "ConsentType" });

            migrationBuilder.CreateIndex(
                name: "IX_ConsentRecords_RegistrationId",
                table: "ConsentRecords",
                column: "RegistrationId");

            migrationBuilder.CreateIndex(
                name: "IX_Countries_Code",
                table: "Countries",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Countries_IsActive_DisplayOrder",
                table: "Countries",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Countries_Name",
                table: "Countries",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Courses_Code",
                table: "Courses",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Courses_IsActive_DisplayOrder",
                table: "Courses",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Courses_Name",
                table: "Courses",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_DisabilityTypes_Code",
                table: "DisabilityTypes",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_DisabilityTypes_IsActive_DisplayOrder",
                table: "DisabilityTypes",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_DisabilityTypes_Name",
                table: "DisabilityTypes",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Districts_Code",
                table: "Districts",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Districts_IsActive_DisplayOrder",
                table: "Districts",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Districts_StateId_Name",
                table: "Districts",
                columns: new[] { "StateId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_EducationLevels_Code",
                table: "EducationLevels",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_EducationLevels_IsActive_DisplayOrder",
                table: "EducationLevels",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_EducationLevels_Name",
                table: "EducationLevels",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Genders_Code",
                table: "Genders",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Genders_IsActive_DisplayOrder",
                table: "Genders",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Genders_Name",
                table: "Genders",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Hobbies_Code",
                table: "Hobbies",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Hobbies_IsActive_DisplayOrder",
                table: "Hobbies",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Hobbies_Name",
                table: "Hobbies",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_InterestAreas_Code",
                table: "InterestAreas",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_InterestAreas_IsActive_DisplayOrder",
                table: "InterestAreas",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_InterestAreas_Name",
                table: "InterestAreas",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MemberAddresses_CityId",
                table: "MemberAddresses",
                column: "CityId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberAddresses_CountryId",
                table: "MemberAddresses",
                column: "CountryId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberAddresses_DistrictId_TalukId",
                table: "MemberAddresses",
                columns: new[] { "DistrictId", "TalukId" });

            migrationBuilder.CreateIndex(
                name: "IX_MemberAddresses_PinCode",
                table: "MemberAddresses",
                column: "PinCode");

            migrationBuilder.CreateIndex(
                name: "IX_MemberAddresses_RegistrationId_AddressType",
                table: "MemberAddresses",
                columns: new[] { "RegistrationId", "AddressType" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MemberAddresses_StateId",
                table: "MemberAddresses",
                column: "StateId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberAddresses_TalukId",
                table: "MemberAddresses",
                column: "TalukId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberDisabilities_DisabilityTypeId",
                table: "MemberDisabilities",
                column: "DisabilityTypeId");

            migrationBuilder.CreateIndex(
                name: "IX_Members_AccountId",
                table: "Members",
                column: "AccountId");

            migrationBuilder.CreateIndex(
                name: "IX_Members_ClassId",
                table: "Members",
                column: "ClassId");

            migrationBuilder.CreateIndex(
                name: "IX_Members_DateOfBirth",
                table: "Members",
                column: "DateOfBirth");

            migrationBuilder.CreateIndex(
                name: "IX_Members_GenderId",
                table: "Members",
                column: "GenderId");

            migrationBuilder.CreateIndex(
                name: "IX_Members_HighestEducationLevelId",
                table: "Members",
                column: "HighestEducationLevelId");

            migrationBuilder.CreateIndex(
                name: "IX_Members_MemberStatusId_ClassId",
                table: "Members",
                columns: new[] { "MemberStatusId", "ClassId" });

            migrationBuilder.CreateIndex(
                name: "IX_Members_OrganisationId",
                table: "Members",
                column: "OrganisationId");

            migrationBuilder.CreateIndex(
                name: "IX_Members_TempleId",
                table: "Members",
                column: "TempleId");

            migrationBuilder.CreateIndex(
                name: "IX_MemberStatuses_Code",
                table: "MemberStatuses",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_MemberStatuses_IsActive_DisplayOrder",
                table: "MemberStatuses",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_MemberStatuses_Name",
                table: "MemberStatuses",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Organisations_IsActive_DisplayOrder",
                table: "Organisations",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Organisations_OrganisationCode",
                table: "Organisations",
                column: "OrganisationCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Organisations_OrganisationName",
                table: "Organisations",
                column: "OrganisationName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_PhoneVerificationChallenges_MobileNumber_CreatedDate",
                table: "PhoneVerificationChallenges",
                columns: new[] { "MobileNumber", "CreatedDate" });

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_AccountId",
                table: "RefreshTokens",
                column: "AccountId");

            migrationBuilder.CreateIndex(
                name: "IX_RefreshTokens_TokenHash",
                table: "RefreshTokens",
                column: "TokenHash",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Code",
                table: "Roles",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Roles_IsActive_DisplayOrder",
                table: "Roles",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Roles_Name",
                table: "Roles",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Skills_Category_IsActive_DisplayOrder",
                table: "Skills",
                columns: new[] { "Category", "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Skills_Code",
                table: "Skills",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Skills_IsActive_DisplayOrder",
                table: "Skills",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Skills_Name",
                table: "Skills",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sports_Code",
                table: "Sports",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Sports_IsActive_DisplayOrder",
                table: "Sports",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Sports_Name",
                table: "Sports",
                column: "Name",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_States_Code",
                table: "States",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_States_CountryId_Name",
                table: "States",
                columns: new[] { "CountryId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_States_IsActive_DisplayOrder",
                table: "States",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Taluks_Code",
                table: "Taluks",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Taluks_DistrictId_Name",
                table: "Taluks",
                columns: new[] { "DistrictId", "Name" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Taluks_IsActive_DisplayOrder",
                table: "Taluks",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Temples_IsActive_DisplayOrder",
                table: "Temples",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Temples_TempleCode",
                table: "Temples",
                column: "TempleCode",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Temples_TempleName",
                table: "Temples",
                column: "TempleName",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Universities_Code",
                table: "Universities",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "IX_Universities_IsActive_DisplayOrder",
                table: "Universities",
                columns: new[] { "IsActive", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "IX_Universities_Name",
                table: "Universities",
                column: "Name",
                unique: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "AccountRoles");

            migrationBuilder.DropTable(
                name: "AchievementTypes");

            migrationBuilder.DropTable(
                name: "AuditLogs");

            migrationBuilder.DropTable(
                name: "Boards");

            migrationBuilder.DropTable(
                name: "Branches");

            migrationBuilder.DropTable(
                name: "CareerOptions");

            migrationBuilder.DropTable(
                name: "CommunicationChannels");

            migrationBuilder.DropTable(
                name: "CommunicationTopics");

            migrationBuilder.DropTable(
                name: "CompetitiveExams");

            migrationBuilder.DropTable(
                name: "ConsentRecords");

            migrationBuilder.DropTable(
                name: "Courses");

            migrationBuilder.DropTable(
                name: "Hobbies");

            migrationBuilder.DropTable(
                name: "InterestAreas");

            migrationBuilder.DropTable(
                name: "MemberAddresses");

            migrationBuilder.DropTable(
                name: "MemberDisabilities");

            migrationBuilder.DropTable(
                name: "PhoneVerificationChallenges");

            migrationBuilder.DropTable(
                name: "RefreshTokens");

            migrationBuilder.DropTable(
                name: "Skills");

            migrationBuilder.DropTable(
                name: "Sports");

            migrationBuilder.DropTable(
                name: "TempleRegistrationSequences");

            migrationBuilder.DropTable(
                name: "Universities");

            migrationBuilder.DropTable(
                name: "Roles");

            migrationBuilder.DropTable(
                name: "Cities");

            migrationBuilder.DropTable(
                name: "DisabilityTypes");

            migrationBuilder.DropTable(
                name: "Members");

            migrationBuilder.DropTable(
                name: "Taluks");

            migrationBuilder.DropTable(
                name: "Accounts");

            migrationBuilder.DropTable(
                name: "Classes");

            migrationBuilder.DropTable(
                name: "EducationLevels");

            migrationBuilder.DropTable(
                name: "Genders");

            migrationBuilder.DropTable(
                name: "MemberStatuses");

            migrationBuilder.DropTable(
                name: "Organisations");

            migrationBuilder.DropTable(
                name: "Temples");

            migrationBuilder.DropTable(
                name: "Districts");

            migrationBuilder.DropTable(
                name: "States");

            migrationBuilder.DropTable(
                name: "Countries");
        }
    }
}
