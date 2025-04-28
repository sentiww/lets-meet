namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class PutMeRequest
{
    public required string Email { get; init; }
    public required string Name { get; set; }
    public required string Surname { get; set; }
    public required DateTimeOffset DateOfBirth { get; set; }
    public required int AvatarId { get; set; }
}