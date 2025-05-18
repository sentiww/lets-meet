using Microsoft.EntityFrameworkCore.Migrations;
using Npgsql.EntityFrameworkCore.PostgreSQL.Metadata;

#nullable disable

namespace LetsMeet.Persistence.Migrations
{
    /// <inheritdoc />
    public partial class EventParticipant : Migration
    {
        /// <inheritdoc />
        protected override void Up(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.RenameColumn(
                name: "isBanned",
                table: "Users",
                newName: "IsBanned");

            migrationBuilder.RenameColumn(
                name: "isAdmin",
                table: "Users",
                newName: "IsAdmin");

            migrationBuilder.CreateTable(
                name: "EventParticipantEntity",
                columns: table => new
                {
                    Id = table.Column<int>(type: "integer", nullable: false)
                        .Annotation("Npgsql:ValueGenerationStrategy", NpgsqlValueGenerationStrategy.IdentityByDefaultColumn),
                    UserId = table.Column<int>(type: "integer", nullable: false),
                    EventId = table.Column<int>(type: "integer", nullable: false)
                },
                constraints: table =>
                {
                    table.PrimaryKey("PK_EventParticipantEntity", x => x.Id);
                    table.ForeignKey(
                        name: "FK_EventParticipantEntity_Events_EventId",
                        column: x => x.EventId,
                        principalTable: "Events",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                    table.ForeignKey(
                        name: "FK_EventParticipantEntity_Users_UserId",
                        column: x => x.UserId,
                        principalTable: "Users",
                        principalColumn: "Id",
                        onDelete: ReferentialAction.Cascade);
                });

            migrationBuilder.CreateIndex(
                name: "IX_EventParticipantEntity_EventId",
                table: "EventParticipantEntity",
                column: "EventId");

            migrationBuilder.CreateIndex(
                name: "IX_EventParticipantEntity_UserId",
                table: "EventParticipantEntity",
                column: "UserId");
        }

        /// <inheritdoc />
        protected override void Down(MigrationBuilder migrationBuilder)
        {
            migrationBuilder.DropTable(
                name: "EventParticipantEntity");

            migrationBuilder.RenameColumn(
                name: "IsBanned",
                table: "Users",
                newName: "isBanned");

            migrationBuilder.RenameColumn(
                name: "IsAdmin",
                table: "Users",
                newName: "isAdmin");
        }
    }
}
