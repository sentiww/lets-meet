namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class PostBlobRequest
{
    public required string Name { get; init; }
    public required byte[] Data { get; init; }
    public required string Extension { get; init; }
    public required string ContentType { get; init; }
}