namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class SignUpRequest
{
    public required string Username { get; init; }
    public required string Password { get; init; }
    public required string Email { get; init; }
    public required string Name { get; init; }
    public required string Surname { get; init; }
    public required DateTimeOffset DateOfBirth { get; init; }
}