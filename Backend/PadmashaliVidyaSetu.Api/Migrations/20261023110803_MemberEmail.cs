using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class MemberEmail : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AlterColumn<string>(
                name: "MobileNumber",
                table: "PVS_PhoneVerificationChallenges",
                type: "varchar(16)",
                unicode: false,
                maxLength: 16,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "varchar(16)",
                oldUnicode: false,
                oldMaxLength: 16);

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "PVS_PhoneVerificationChallenges",
                type: "varchar(254)",
                unicode: false,
                maxLength: 254,
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Email",
                table: "PVS_Members",
                type: "varchar(254)",
                unicode: false,
                maxLength: 254,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "EmailVerifiedDate",
                table: "PVS_Members",
                type: "datetime2(3)",
                nullable: true);

            migrationBuilder.CreateIndex(
                name: "PVS_IX_PhoneVerificationChallenges_Email_CreatedDate",
                table: "PVS_PhoneVerificationChallenges",
                columns: new[] { "Email", "CreatedDate" });

            migrationBuilder.AddCheckConstraint(
                name: "PVS_CK_PhoneVerificationChallenges_Target",
                table: "PVS_PhoneVerificationChallenges",
                sql: "([MobileNumber] IS NOT NULL AND [Email] IS NULL) OR ([MobileNumber] IS NULL AND [Email] IS NOT NULL)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropIndex(
                name: "PVS_IX_PhoneVerificationChallenges_Email_CreatedDate",
                table: "PVS_PhoneVerificationChallenges");

            migrationBuilder.DropCheckConstraint(
                name: "PVS_CK_PhoneVerificationChallenges_Target",
                table: "PVS_PhoneVerificationChallenges");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "PVS_PhoneVerificationChallenges");

            migrationBuilder.DropColumn(
                name: "Email",
                table: "PVS_Members");

            migrationBuilder.DropColumn(
                name: "EmailVerifiedDate",
                table: "PVS_Members");

            migrationBuilder.AlterColumn<string>(
                name: "MobileNumber",
                table: "PVS_PhoneVerificationChallenges",
                type: "varchar(16)",
                unicode: false,
                maxLength: 16,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "varchar(16)",
                oldUnicode: false,
                oldMaxLength: 16,
                oldNullable: true);
        }
    }
}
