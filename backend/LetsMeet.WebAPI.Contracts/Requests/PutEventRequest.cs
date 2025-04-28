public sealed class PostEventRequest
{
    public required string Title { get; init; }
    public string? Description { get; init; }

    public required DateTime EventDate { get; init; }
    public required List<int> PhotoBlobIds { get; init; }
}