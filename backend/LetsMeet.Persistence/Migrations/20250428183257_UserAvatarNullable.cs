using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LetsMeet.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class UserAvatarNullable : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Blobs_Users_OwnerId",
                table: "Blobs");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Blobs_AvatarId",
                table: "Users");

            migrationBuilder.AlterColumn<int>(
                name: "AvatarId",
                table: "Users",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AlterColumn<int>(
                name: "OwnerId",
                table: "Blobs",
                type: "integer",
                nullable: true,
                oldClrType: typeof(int),
                oldType: "integer");

            migrationBuilder.AddForeignKey(
                name: "FK_Blobs_Users_OwnerId",
                table: "Blobs",
                column: "OwnerId",
                principalTable: "Users",
                principalColumn: "Id");

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Blobs_AvatarId",
                table: "Users",
                column: "AvatarId",
                principalTable: "Blobs",
                principalColumn: "Id");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropForeignKey(
                name: "FK_Blobs_Users_OwnerId",
                table: "Blobs");

            migrationBuilder.DropForeignKey(
                name: "FK_Users_Blobs_AvatarId",
                table: "Users");

            migrationBuilder.AlterColumn<int>(
                name: "AvatarId",
                table: "Users",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AlterColumn<int>(
                name: "OwnerId",
                table: "Blobs",
                type: "integer",
                nullable: false,
                defaultValue: 0,
                oldClrType: typeof(int),
                oldType: "integer",
                oldNullable: true);

            migrationBuilder.AddForeignKey(
                name: "FK_Blobs_Users_OwnerId",
                table: "Blobs",
                column: "OwnerId",
                principalTable: "Users",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);

            migrationBuilder.AddForeignKey(
                name: "FK_Users_Blobs_AvatarId",
                table: "Users",
                column: "AvatarId",
                principalTable: "Blobs",
                principalColumn: "Id",
                onDelete: ReferentialAction.Cascade);
        }
    }
}
