namespace LetsMeet.WebAPI.Contracts.Requests;

public sealed class PostBlobRequest
{
    public required string Name { get; init; }
    public required byte[] Data { get; init; }
}