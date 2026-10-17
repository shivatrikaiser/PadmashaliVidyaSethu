using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class AppBranding : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PVS_AppBranding",
                columns: table => new
                {
                    AppBrandingId = table.Column<int>(type: "int", nullable: false),
                    SponsorName = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    SponsorLogo = table.Column<byte[]>(type: "varbinary(max)", nullable: true),
                    SponsorLogoContentType = table.Column<string>(type: "varchar(30)", unicode: false, maxLength: 30, nullable: true),
                    PoweredBy = table.Column<string>(type: "nvarchar(150)", maxLength: 150, nullable: true),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_AppBranding", x => x.AppBrandingId);
                    table.CheckConstraint("PVS_CK_AppBranding_Singleton", "[AppBrandingId] = 1");
                });

            migrationBuilder.InsertData(
                table: "PVS_AppBranding",
                columns: new[] { "AppBrandingId", "ModifiedBy", "ModifiedDate", "PoweredBy", "SponsorLogo", "SponsorLogoContentType", "SponsorName" },
                values: new object[] { 1, null, null, "IQ Explore", null, null, null });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PVS_AppBranding");
        }
    }
}
