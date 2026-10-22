using System;
using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace PadmashaliVidyaSetu.Api.Migrations
{
    /// <inheritdoc />
    public partial class PushNotifications : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.CreateTable(
                name: "PVS_PushNotifications",
                columns: table => new
                {
                    PushNotificationId = table.Column<int>(type: "int", nullable: false)
                        .Annotation("SqlServer:Identity", "1, 1"),
                    Title = table.Column<string>(type: "nvarchar(65)", maxLength: 65, nullable: false),
                    Body = table.Column<string>(type: "nvarchar(240)", maxLength: 240, nullable: false),
                    Topic = table.Column<string>(type: "varchar(100)", unicode: false, maxLength: 100, nullable: false),
                    FcmMessageId = table.Column<string>(type: "varchar(200)", unicode: false, maxLength: 200, nullable: true),
                    SentDate = table.Column<DateTime>(type: "datetime2(3)", nullable: false),
                    SentBy = table.Column<string>(type: "nvarchar(100)", maxLength: 100, nullable: true)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PVS_PK_PushNotifications", x => x.PushNotificationId);
                });

            migrationBuilder.CreateIndex(
                name: "PVS_IX_PushNotifications_SentDate",
                table: "PVS_PushNotifications",
                column: "SentDate");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "PVS_PushNotifications");
        }
    }
}
