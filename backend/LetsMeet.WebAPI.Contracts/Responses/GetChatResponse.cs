namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetChatResponse
{
    public required int Id { get; init; }
    public required int Type { get; init; }
    public required string Name { get; init; }
    public required IEnumerable<int> UserIds { get; init; }
    public required IEnumerable<Message> Messages { get; init; }
    
    public sealed class Message
    {
        public required int Id { get; init; }
        public required int FromId { get; init; }
        public required DateTime SentAt { get; init; }
        public required string Content { get; init; }
    }
}