namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetFeedResponse
{
    public int EventId { get; init; }
    public string? Title { get; init; }
    public string? Description { get; init; }
    public int CreatedBy { get; init; }
    public IEnumerable<int> PhotoIds { get; init; }
    public IEnumerable<int> ParticipantIds { get; init; }
}