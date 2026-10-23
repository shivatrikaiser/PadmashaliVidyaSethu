using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class FooterSponsors : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "PoweredByUrl",
                table: "PVS_AppBranding",
                type: "nvarchar(500)",
                maxLength: 500,
                nullable: true);

            migrationBuilder.CreateTable(
                name: "PVS_FooterSponsors",
                columns: table => new
                {
                    FooterSponsorId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Name = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: false),
                    Designation = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    CompanyName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    DisplayOrder = table.Column<int>(type: "int", nullable: false),
                    CreatedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false, defaultValueSql: "SYSUTCDATETIME()")
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_FooterSponsors_CreatedDate"),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    CreatedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true),
                    IsActive = table.Column<bool>(type: "bit", nullable: false, defaultValue: true)
                        .Annotation("Relational:DefaultConstraintName", "PVS_DF_FooterSponsors_IsActive")
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_FooterSponsors", x => x.FooterSponsorId);
                });

            migrationBuilder.UpdateData(
                table: "PVS_AppBranding",
                keyColumn: "AppBrandingId",
                keyValue: 1,
                column: "PoweredByUrl",
                value: "https://play.google.com/store/apps/details?id=com.iqexplore.app");

            migrationBuilder.CreateIndex(
                name: "PVS_IX_FooterSponsors_IsActive_DisplayOrder",
                table: "PVS_FooterSponsors",
                columns: new[] { "IsActive", "DisplayOrder" });

            // The footer now lists sponsors: start the list with the sponsor already set (name + organisation).
            migrationBuilder.Sql(
                "INSERT INTO [PVS_FooterSponsors] ([Name], [CompanyName], [DisplayOrder], [CreatedBy]) " +
                "SELECT [SponsorName], [SponsorOrganisation], 0, N'migration' FROM [PVS_AppBranding] " +
                "WHERE [AppBrandingId] = 1 AND NULLIF(LTRIM(RTRIM([SponsorName])), N'') IS NOT NULL;");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PVS_FooterSponsors");

            migrationBuilder.DropColumn(
                name: "PoweredByUrl",
                table: "PVS_AppBranding");
        }
    }
}
