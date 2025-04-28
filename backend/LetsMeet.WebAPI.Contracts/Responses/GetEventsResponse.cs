namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetEventsResponse
{
    public required IEnumerable<Event> Events { get; init; }
}

public sealed class Event
{
    public required int Id { get; init; }
    public required string Title { get; init; }
}