using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class AddressOutsideIndia : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "PVS_CK_MemberAddresses_PinCode",
                table: "PVS_MemberAddresses");

            migrationBuilder.AlterColumn<int>(
                name: "TalukId",
                table: "PVS_MemberAddresses",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AlterColumn<string>(
                name: "PinCode",
                table: "PVS_MemberAddresses",
                type: "varchar(10)",
                unicode: false,
                maxLength: 10,
                nullable: true,
                oldClrType: typeof(string),
                oldType: "char(6)",
                oldUnicode: false,
                oldFixedLength: true,
                oldMaxLength: 6);

            migrationBuilder.AlterColumn<int>(
                name: "DistrictId",
                table: "PVS_MemberAddresses",
                type: "int",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "int");

            migrationBuilder.AddCheckConstraint(
                name: "PVS_CK_MemberAddresses_CountryRules",
                table: "PVS_MemberAddresses",
                sql: "([CountryId] = 1 AND [PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]' AND [DistrictId] IS NOT NULL AND [TalukId] IS NOT NULL) OR ([CountryId] <> 1 AND [DistrictId] IS NULL AND [TalukId] IS NULL AND [CityId] IS NULL)");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropCheckConstraint(
                name: "PVS_CK_MemberAddresses_CountryRules",
                table: "PVS_MemberAddresses");

            migrationBuilder.AlterColumn<int>(
                name: "TalukId",
                table: "PVS_MemberAddresses",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AlterColumn<string>(
                name: "PinCode",
                table: "PVS_MemberAddresses",
                type: "char(6)",
                unicode: false,
                fixedLength: true,
                maxLength: 6,
                nullable: false,
                defaultValue: "",
                oldClrType: typeof(string),
                oldType: "varchar(10)",
                oldUnicode: false,
                oldMaxLength: 10,
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "DistrictId",
                table: "PVS_MemberAddresses",
                type: "int",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "int",
                oldNullable: true);

            migrationBuilder.AddCheckConstraint(
                name: "PVS_CK_MemberAddresses_PinCode",
                table: "PVS_MemberAddresses",
                sql: "[PinCode] LIKE '[1-9][0-9][0-9][0-9][0-9][0-9]'");
        }
    }
}
