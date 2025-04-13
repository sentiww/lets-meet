namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class RefreshTokenResponse
{
    public required string Token { get; init; }
    public required string RefreshToken { get; init; }
}