namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetBlobResponse
{
    public required string Name { get; init; }
    public required byte[] Data { get; init; }
}