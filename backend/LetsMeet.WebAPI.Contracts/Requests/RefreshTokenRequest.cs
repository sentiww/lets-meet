namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class RefreshTokenRequest
{
    public required string Token { get; init; }
}