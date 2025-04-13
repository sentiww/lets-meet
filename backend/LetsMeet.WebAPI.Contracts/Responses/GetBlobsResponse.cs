namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetBlobsResponse
{
    public required IEnumerable<Blob> Blobs { get; init; }
}

public sealed class Blob
{
    public required int Id { get; init; }
    public required string Name { get; init; }
}