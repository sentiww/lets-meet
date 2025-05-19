namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetLikedEventsResponse
{
    public required IEnumerable<Event> Events { get; init; }
    
    public sealed class Event
    {
        public required int EventId { get; init; }
    }
}