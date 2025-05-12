using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LetsMeet.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class ModerationMigration : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.AddColumn<bool>(
                name: "isAdmin",
                table: "Users",
                type: "boolean",
                nullable: false,
                defaultValue: false);

            migrationBuilder.AddColumn<bool>(
                name: "isBanned",
                table: "Users",
                type: "boolean",
                nullable: false,
                defaultValue: false);
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "isAdmin",
                table: "Users");

            migrationBuilder.DropColumn(
                name: "isBanned",
                table: "Users");
        }
    }
}
