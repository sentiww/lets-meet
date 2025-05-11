using Microsoft.AspNetCore.Mvc;

namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class GetEventRequest
{
    [FromQuery]
    public required int EventId { get; init; }
}