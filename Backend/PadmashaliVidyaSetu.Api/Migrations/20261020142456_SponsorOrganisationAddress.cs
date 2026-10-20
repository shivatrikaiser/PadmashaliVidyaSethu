using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class SponsorOrganisationAddress : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<string>(
                name: "SponsorAddress",
                table: "PVS_AppBranding",
                type: "nvarchar(300)",
                maxLength: 300,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "SponsorOrganisation",
                table: "PVS_AppBranding",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: true);

            migrationBuilder.UpdateData(
                table: "PVS_AppBranding",
                keyColumn: "AppBrandingId",
                keyValue: 1,
                columns: new[] { "SponsorAddress", "SponsorOrganisation" },
                values: new object[] { null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "SponsorAddress",
                table: "PVS_AppBranding");

            migrationBuilder.DropColumn(
                name: "SponsorOrganisation",
                table: "PVS_AppBranding");
        }
    }
}
