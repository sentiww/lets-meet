using Microsoft.AspNetCore.Mvc;

namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class DeleteEventRequest
{
    [FromQuery]
    public required int EventId { get; init; }
}