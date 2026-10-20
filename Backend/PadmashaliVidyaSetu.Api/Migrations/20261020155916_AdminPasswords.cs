using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class AdminPasswords : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<int>(
                name: "FailedPasswordAttempts",
                table: "PVS_Accounts",
                type: "int",
                nullable: false,
                defaultValue: 0)
                .Annotation("Relational:DefaultConstraintName", "PVS_DF_Accounts_FailedPasswordAttempts");

            migrationBuilder.AddColumn<string>(
                name: "PasswordHash",
                table: "PVS_Accounts",
                type: "varchar(200)",
                unicode: false,
                maxLength: 200,
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordLockedUntil",
                table: "PVS_Accounts",
                type: "datetime2(3)",
                nullable: true);

            migrationBuilder.AddColumn<DateTime>(
                name: "PasswordSetDate",
                table: "PVS_Accounts",
                type: "datetime2(3)",
                nullable: true);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "FailedPasswordAttempts",
                table: "PVS_Accounts")
                .Annotation("Relational:DefaultConstraintName", "PVS_DF_Accounts_FailedPasswordAttempts");

            migrationBuilder.DropColumn(
                name: "PasswordHash",
                table: "PVS_Accounts");

            migrationBuilder.DropColumn(
                name: "PasswordLockedUntil",
                table: "PVS_Accounts");

            migrationBuilder.DropColumn(
                name: "PasswordSetDate",
                table: "PVS_Accounts");
        }
    }
}
