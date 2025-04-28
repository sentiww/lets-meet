using Microsoft.EntityFrameworkCore.Migrations;

#nullable disable

namespace LetsMeet.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class BlobContentType : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "Stream",
                table: "Blobs",
                newName: "Data");

            migrationBuilder.AddColumn<string>(
                name: "ContentType",
                table: "Blobs",
                type: "text",
                nullable: false,
                defaultValue: "");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropColumn(
                name: "ContentType",
                table: "Blobs");

            migrationBuilder.RenameColumn(
                name: "Data",
                table: "Blobs",
                newName: "Stream");
        }
    }
}
