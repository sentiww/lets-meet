namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetChatMessageResponse
{
    public required int Id { get; init; }
    public required int FromId { get; init; }
    public required DateTime SentAt { get; init; }
    public required string Content { get; init; }
}