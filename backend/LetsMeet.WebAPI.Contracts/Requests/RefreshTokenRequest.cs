using Microsoft.AspNetCore.Mvc;

namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class RefreshTokenRequest
{
    [FromBody]
    public required string RefreshToken { get; init; }
}