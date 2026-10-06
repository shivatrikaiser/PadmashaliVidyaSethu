using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

#pragma warning disable CA1814 // Prefer jagged arrays over multidimensional

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class TemplesAndSmsVerification : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "TempleRegistrationSequences",
                keyColumn: "TempleId",
                keyValue: 16);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 6);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 7);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 8);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 9);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 10);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 11);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 12);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 13);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 14);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 15);

            migrationBuilder.DeleteData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 16);

            migrationBuilder.AlterColumn<string>(
                name: "TempleName",
                table: "Temples",
                type: "nvarchar(200)",
                maxLength: 200,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(150)",
                oldMaxLength: 150);

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 1,
                column: "TempleName",
                value: "Barkur");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 2,
                column: "TempleName",
                value: "Mangaluru");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 3,
                column: "TempleName",
                value: "Kallianapura");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 4,
                column: "TempleName",
                value: "Salikeri");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 5,
                column: "TempleName",
                value: "Kinnimulky");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "TempleName",
                table: "Temples",
                type: "nvarchar(150)",
                maxLength: 150,
                nullable: false,
                oldClrType: typeof(string),
                oldType: "nvarchar(200)",
                oldMaxLength: 200);

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 1,
                column: "TempleName",
                value: "Temple 01 (Placeholder - update name)");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 2,
                column: "TempleName",
                value: "Temple 02 (Placeholder - update name)");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 3,
                column: "TempleName",
                value: "Temple 03 (Placeholder - update name)");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 4,
                column: "TempleName",
                value: "Temple 04 (Placeholder - update name)");

            migrationBuilder.UpdateData(
                table: "Temples",
                keyColumn: "TempleId",
                keyValue: 5,
                column: "TempleName",
                value: "Temple 05 (Placeholder - update name)");

            migrationBuilder.InsertData(
                table: "Temples",
                columns: new[] { "TempleId", "TempleCode", "CreatedBy", "CreatedDate", "DisplayOrder", "IsActive", "ModifiedBy", "ModifiedDate", "TempleName" },
                values: new object[,]
                {
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
                table: "TempleRegistrationSequences",
                columns: new[] { "TempleId", "LastSequenceNumber" },
                values: new object[,]
                {
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
        }
    }
}
