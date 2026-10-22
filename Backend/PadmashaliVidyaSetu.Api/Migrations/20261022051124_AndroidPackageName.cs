using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <summary>
    /// The Android package name became <c>com.vidyasethu.pvs</c>: point the "Update now" Play Store link at it.
    /// Only the original link is replaced - a link changed since (04_ReleaseAppVersion) is left alone.
    /// </summary>
    public partial class AndroidPackageName : Migration
    {
        private const string OldUrl = "https://play.google.com/store/apps/details?id=org.padmashalividyasetu.padmashali_vidya_setu";
        private const string NewUrl = "https://play.google.com/store/apps/details?id=com.vidyasethu.pvs";

        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                $"UPDATE [PVS_AppVersions] SET [StoreUrl] = N'{NewUrl}' WHERE [Platform] = 'android' AND [StoreUrl] = N'{OldUrl}';");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.Sql(
                $"UPDATE [PVS_AppVersions] SET [StoreUrl] = N'{OldUrl}' WHERE [Platform] = 'android' AND [StoreUrl] = N'{NewUrl}';");
        }
    }
}
