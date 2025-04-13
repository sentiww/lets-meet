namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetMeResponse
{
    public required int Id { get; init; }
    public required string Username { get; init; }
    public required string Name { get; init; }
    public required string Surname { get; init; }
    public required DateTimeOffset DateOfBirth { get; init; }
    public required string Email { get; init; }
}