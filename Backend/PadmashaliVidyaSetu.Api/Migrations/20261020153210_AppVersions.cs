using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class AppVersions : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PVS_AppVersions",
                columns: table => new
                {
                    Platform = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    LatestVersion = table.Column<string>(type: "varchar(20)", unicode: false, maxLength: 20, nullable: false),
                    IsMandatory = table.Column<bool>(type: "bit", nullable: false),
                    StoreUrl = table.Column<string>(type: "nvarchar(500)", maxLength: 500, nullable: true),
                    ModifiedDate = table.Column<DateTime>(type: "datetime2(3)", nullable: true),
                    ModifiedBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_AppVersions", x => x.Platform);
                    table.CheckConstraint("PVS_CK_AppVersions_LatestVersion", "[LatestVersion] LIKE '[0-9]%.[0-9]%.[0-9]%' AND [LatestVersion] NOT LIKE '%[^0-9.]%'");
                    table.CheckConstraint("PVS_CK_AppVersions_Platform", "[Platform] IN ('android', 'ios')");
                });

            migrationBuilder.InsertData(
                table: "PVS_AppVersions",
                columns: new[] { "Platform", "IsMandatory", "LatestVersion", "ModifiedBy", "ModifiedDate", "StoreUrl" },
                values: new object[,]
                {
                    { "android", true, "1.0.0", null, null, "https://play.google.com/store/apps/details?id=org.padmashalividyasetu.padmashali_vidya_setu" },
                    { "ios", true, "1.0.0", null, null, null }
                });
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PVS_AppVersions");
        }
    }
}
