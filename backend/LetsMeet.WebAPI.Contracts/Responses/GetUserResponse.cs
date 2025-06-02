namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetUserResponse
{
    public required int Id { get; init; }
    public required string Username { get; init; }

    public int? AvatarId { get; init; }
}