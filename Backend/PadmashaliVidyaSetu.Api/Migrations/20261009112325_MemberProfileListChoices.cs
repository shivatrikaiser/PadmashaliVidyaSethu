using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class MemberProfileListChoices : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PVS_AcademicAchievements",
                columns: table => new
                {
                    AcademicAchievementId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    AchievementTypeId = table.Column<int>(type: "int", nullable: false),
                    AchievementTypeOtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_AcademicAchievements_CreatedDate"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_AcademicAchievements_IsActive")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_AcademicAchievements", x => x.AcademicAchievementId);
                    table.ForeignKey(
                        name: "PVS_FK_AcademicAchievements_AchievementTypes_AchievementTypeId",
                        column: x => x.AchievementTypeId,
                        principalTable: "PVS_AchievementTypes",
                        principalColumn: "AchievementTypeId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_AcademicAchievements_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PVS_MemberCareerAspirations",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    CareerOptionId = table.Column<int>(type: "int", nullable: false),
                    OtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberCareerAspirations_CreatedDate"),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_MemberCareerAspirations", x => new { x.RegistrationId, x.CareerOptionId });
                    table.ForeignKey(
                        name: "PVS_FK_MemberCareerAspirations_CareerOptions_CareerOptionId",
                        column: x => x.CareerOptionId,
                        principalTable: "PVS_CareerOptions",
                        principalColumn: "CareerOptionId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberCareerAspirations_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PVS_MemberCompetitiveExams",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    CompetitiveExamId = table.Column<int>(type: "int", nullable: false),
                    OtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberCompetitiveExams_CreatedDate"),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_MemberCompetitiveExams", x => new { x.RegistrationId, x.CompetitiveExamId });
                    table.ForeignKey(
                        name: "PVS_FK_MemberCompetitiveExams_CompetitiveExams_CompetitiveExamId",
                        column: x => x.CompetitiveExamId,
                        principalTable: "PVS_CompetitiveExams",
                        principalColumn: "CompetitiveExamId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberCompetitiveExams_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PVS_MemberEducation",
                columns: table => new
                {
                    MemberEducationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    EducationLevelId = table.Column<int>(type: "int", nullable: false),
                    EducationLevelOtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CourseId = table.Column<int>(type: "int", nullable: true),
                    CourseOtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    BranchId = table.Column<int>(type: "int", nullable: true),
                    BranchOtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    BoardId = table.Column<int>(type: "int", nullable: true),
                    BoardOtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberEducation_CreatedDate"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberEducation_IsActive")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_MemberEducation", x => x.MemberEducationId);
                    table.ForeignKey(
                        name: "PVS_FK_MemberEducation_Boards_BoardId",
                        column: x => x.BoardId,
                        principalTable: "PVS_Boards",
                        principalColumn: "BoardId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberEducation_Branches_BranchId",
                        column: x => x.BranchId,
                        principalTable: "PVS_Branches",
                        principalColumn: "BranchId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberEducation_Courses_CourseId",
                        column: x => x.CourseId,
                        principalTable: "PVS_Courses",
                        principalColumn: "CourseId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberEducation_EducationLevels_EducationLevelId",
                        column: x => x.EducationLevelId,
                        principalTable: "PVS_EducationLevels",
                        principalColumn: "EducationLevelId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberEducation_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PVS_MemberHobbies",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    HobbyId = table.Column<int>(type: "int", nullable: false),
                    OtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberHobbies_CreatedDate"),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_MemberHobbies", x => new { x.RegistrationId, x.HobbyId });
                    table.ForeignKey(
                        name: "PVS_FK_MemberHobbies_Hobbies_HobbyId",
                        column: x => x.HobbyId,
                        principalTable: "PVS_Hobbies",
                        principalColumn: "HobbyId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberHobbies_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PVS_MemberInterestAreas",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    InterestAreaId = table.Column<int>(type: "int", nullable: false),
                    OtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberInterestAreas_CreatedDate"),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_MemberInterestAreas", x => new { x.RegistrationId, x.InterestAreaId });
                    table.ForeignKey(
                        name: "PVS_FK_MemberInterestAreas_InterestAreas_InterestAreaId",
                        column: x => x.InterestAreaId,
                        principalTable: "PVS_InterestAreas",
                        principalColumn: "InterestAreaId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_MemberInterestAreas_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateTable(
                name: "PVS_MemberSkills",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    SkillId = table.Column<int>(type: "int", nullable: false),
                    OtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberSkills_CreatedDate"),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_MemberSkills", x => new { x.RegistrationId, x.SkillId });
                    table.ForeignKey(
                        name: "PVS_FK_MemberSkills_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "PVS_FK_MemberSkills_Skills_SkillId",
                        column: x => x.SkillId,
                        principalTable: "PVS_Skills",
                        principalColumn: "SkillId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PVS_MemberSports",
                columns: table => new
                {
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    SportId = table.Column<int>(type: "int", nullable: false),
                    OtherText = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_MemberSports_CreatedDate"),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_MemberSports", x => new { x.RegistrationId, x.SportId });
                    table.ForeignKey(
                        name: "PVS_FK_MemberSports_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "PVS_FK_MemberSports_Sports_SportId",
                        column: x => x.SportId,
                        principalTable: "PVS_Sports",
                        principalColumn: "SportId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateIndex(
                name: "PVS_IX_AcademicAchievements_AchievementTypeId",
                table: "PVS_AcademicAchievements",
                column: "AchievementTypeId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_AcademicAchievements_RegistrationId",
                table: "PVS_AcademicAchievements",
                column: "RegistrationId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberCareerAspirations_CareerOptionId",
                table: "PVS_MemberCareerAspirations",
                column: "CareerOptionId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberCompetitiveExams_CompetitiveExamId",
                table: "PVS_MemberCompetitiveExams",
                column: "CompetitiveExamId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberEducation_BoardId",
                table: "PVS_MemberEducation",
                column: "BoardId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberEducation_BranchId",
                table: "PVS_MemberEducation",
                column: "BranchId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberEducation_CourseId",
                table: "PVS_MemberEducation",
                column: "CourseId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberEducation_EducationLevelId",
                table: "PVS_MemberEducation",
                column: "EducationLevelId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberEducation_RegistrationId",
                table: "PVS_MemberEducation",
                column: "RegistrationId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberHobbies_HobbyId",
                table: "PVS_MemberHobbies",
                column: "HobbyId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberInterestAreas_InterestAreaId",
                table: "PVS_MemberInterestAreas",
                column: "InterestAreaId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberSkills_SkillId",
                table: "PVS_MemberSkills",
                column: "SkillId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_MemberSports_SportId",
                table: "PVS_MemberSports",
                column: "SportId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PVS_AcademicAchievements");

            migrationBuilder.DropTable(
                name: "PVS_MemberCareerAspirations");

            migrationBuilder.DropTable(
                name: "PVS_MemberCompetitiveExams");

            migrationBuilder.DropTable(
                name: "PVS_MemberEducation");

            migrationBuilder.DropTable(
                name: "PVS_MemberHobbies");

            migrationBuilder.DropTable(
                name: "PVS_MemberInterestAreas");

            migrationBuilder.DropTable(
                name: "PVS_MemberSkills");

            migrationBuilder.DropTable(
                name: "PVS_MemberSports");
        }
    }
}
