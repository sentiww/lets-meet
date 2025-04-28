namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetEventResponse
{

    public required int Id { get; init; }
    public required string Title { get; init; }
    public string? Description { get; init; }

    public required DateTime EventDate { get; init; }

    public required IEnumerable<int> PhotoIds { get; init; }

}