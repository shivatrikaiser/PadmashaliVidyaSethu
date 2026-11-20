using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class EventRegistrations : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PVS_Events",
                columns: table => new
                {
                    EventId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Code = table.Column<string>(type: "varchar(12)", unicode: false, maxLength: 12, nullable: false),
                    Title = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Description = table.Column<string>(type: "nvarchar(2000)", maxLength: 2000, nullable: true),
                    Venue = table.Column<string>(type: "nvarchar(300)", maxLength: 300, nullable: true),
                    EventDate = table.Column<DateOnly>(type: "date", nullable: false),
                    AgeAsOnDate = table.Column<DateOnly>(type: "date", nullable: false),
                    RegistrationOpensDate = table.Column<DateOnly>(type: "date", nullable: false),
                    RegistrationClosesDate = table.Column<DateOnly>(type: "date", nullable: false),
                    MaxGroupsPerMember = table.Column<int>(type: "int", nullable: false),
                    IsPublished = table.Column<bool>(type: "bit", nullable: false),
                    LastRegistrationNumber = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_Events_CreatedDate"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_Events_IsActive")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_Events", x => x.EventId);
                    table.CheckConstraint("PVS_CK_Events_Code", "LEN([Code]) >= 2 AND [Code] NOT LIKE '%[^A-Z0-9]%'");
                    table.CheckConstraint("PVS_CK_Events_LastRegistrationNumber", "[LastRegistrationNumber] BETWEEN 0 AND 9999");
                    table.CheckConstraint("PVS_CK_Events_MaxGroupsPerMember", "[MaxGroupsPerMember] BETWEEN 1 AND 50");
                    table.CheckConstraint("PVS_CK_Events_RegistrationDates", "[RegistrationOpensDate] <= [RegistrationClosesDate]");
                });

            migrationBuilder.CreateTable(
                name: "PVS_EventGroups",
                columns: table => new
                {
                    EventGroupId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    EventId = table.Column<int>(type: "int", nullable: false),
                    Name = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: false),
                    MinAge = table.Column<int>(type: "int", nullable: false),
                    MaxAge = table.Column<int>(type: "int", nullable: false),
                    GenderId = table.Column<int>(type: "int", nullable: true),
                    Capacity = table.Column<int>(type: "int", nullable: true),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_EventGroups_CreatedDate"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_EventGroups_IsActive")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_EventGroups", x => x.EventGroupId);
                    table.CheckConstraint("PVS_CK_EventGroups_Ages", "[MinAge] >= 0 AND [MaxAge] <= 120 AND [MinAge] <= [MaxAge]");
                    table.CheckConstraint("PVS_CK_EventGroups_Capacity", "[Capacity] IS NULL OR [Capacity] >= 1");
                    table.ForeignKey(
                        name: "PVS_FK_EventGroups_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "PVS_Events",
                        principalColumn: "EventId",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "PVS_FK_EventGroups_Genders_GenderId",
                        column: x => x.GenderId,
                        principalTable: "PVS_Genders",
                        principalColumn: "GenderId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PVS_EventRegistrations",
                columns: table => new
                {
                    EventRegistrationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    EventId = table.Column<int>(type: "int", nullable: false),
                    RegistrationId = table.Column<string>(type: "char(11)", unicode: false, fixedLength: true, maxLength: 11, nullable: false),
                    RegistrationNumber = table.Column<string>(type: "varchar(17)", unicode: false, maxLength: 17, nullable: false),
                    AgeOnAgeAsOnDate = table.Column<int>(type: "int", nullable: false),
                    RegisteredDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    CancelledDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_EventRegistrations_CreatedDate"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_EventRegistrations_IsActive")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_EventRegistrations", x => x.EventRegistrationId);
                    table.ForeignKey(
                        name: "PVS_FK_EventRegistrations_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "PVS_Events",
                        principalColumn: "EventId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_EventRegistrations_Members_RegistrationId",
                        column: x => x.RegistrationId,
                        principalTable: "PVS_Members",
                        principalColumn: "RegistrationId",
                        onDelete: ReferentialAction.Restrict);
                });

            migrationBuilder.CreateTable(
                name: "PVS_EventRegistrationGroups",
                columns: table => new
                {
                    EventRegistrationId = table.Column<int>(type: "int", nullable: false),
                    EventGroupId = table.Column<int>(type: "int", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_EventRegistrationGroups", x => new { x.EventRegistrationId, x.EventGroupId });
                    table.ForeignKey(
                        name: "PVS_FK_EventRegistrationGroups_EventGroups_EventGroupId",
                        column: x => x.EventGroupId,
                        principalTable: "PVS_EventGroups",
                        principalColumn: "EventGroupId",
                        onDelete: ReferentialAction.Restrict);
                    table.ForeignKey(
                        name: "PVS_FK_EventRegistrationGroups_EventRegistrations_EventRegistrationId",
                        column: x => x.EventRegistrationId,
                        principalTable: "PVS_EventRegistrations",
                        principalColumn: "EventRegistrationId",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "PVS_IX_EventGroups_EventId_DisplayOrder",
                table: "PVS_EventGroups",
                columns: new[] { "EventId", "DisplayOrder" });

            migrationBuilder.CreateIndex(
                name: "PVS_IX_EventGroups_GenderId",
                table: "PVS_EventGroups",
                column: "GenderId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_EventRegistrationGroups_EventGroupId",
                table: "PVS_EventRegistrationGroups",
                column: "EventGroupId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_EventRegistrations_EventId_RegistrationId",
                table: "PVS_EventRegistrations",
                columns: new[] { "EventId", "RegistrationId" },
                unique: true);

            migrationBuilder.CreateIndex(
                name: "PVS_IX_EventRegistrations_RegistrationId",
                table: "PVS_EventRegistrations",
                column: "RegistrationId");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_EventRegistrations_RegistrationNumber",
                table: "PVS_EventRegistrations",
                column: "RegistrationNumber",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "PVS_IX_Events_Code",
                table: "PVS_Events",
                column: "Code",
                unique: true);

            migrationBuilder.CreateIndex(
                name: "PVS_IX_Events_IsActive_IsPublished_RegistrationClosesDate",
                table: "PVS_Events",
                columns: new[] { "IsActive", "IsPublished", "RegistrationClosesDate" });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PVS_EventRegistrationGroups");

            migrationBuilder.DropTable(
                name: "PVS_EventGroups");

            migrationBuilder.DropTable(
                name: "PVS_EventRegistrations");

            migrationBuilder.DropTable(
                name: "PVS_Events");
        }
    }
}
