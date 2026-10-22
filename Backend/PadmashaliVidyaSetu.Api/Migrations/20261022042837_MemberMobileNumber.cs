using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class MemberMobileNumber : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "AccountId",
                table: "PVS_PhoneVerificationChallenges",
                type: "int",
                nullable: true);

            migrationBuilder.AddColumn<string>(
                name: "Purpose",
                table: "PVS_PhoneVerificationChallenges",
                type: "varchar(20)",
                unicode: false,
                maxLength: 20,
                nullable: false,
                defaultValue: "SIGN_IN")
                .Annotation("Relational:DefaultConstraintName", "PVS_DF_PhoneVerificationChallenges_Purpose");

            migrationBuilder.AddColumn<string>(
                name: "MobileNumber",
                table: "PVS_Members",
                type: "varchar(16)",
                unicode: false,
                maxLength: 16,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "MobileVerifiedDate",
                table: "PVS_Members",
                type: "datetime2(3)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "AccountId",
                table: "PVS_PhoneVerificationChallenges");

            migrationBuilder.DropColumn(
                name: "Purpose",
                table: "PVS_PhoneVerificationChallenges")
                .Annotation("Relational:DefaultConstraintName", "PVS_DF_PhoneVerificationChallenges_Purpose");

            migrationBuilder.DropColumn(
                name: "MobileNumber",
                table: "PVS_Members");

            migrationBuilder.DropColumn(
                name: "MobileVerifiedDate",
                table: "PVS_Members");
        }
    }
}
