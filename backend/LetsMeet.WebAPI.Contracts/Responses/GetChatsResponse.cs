namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetChatsResponse
{
    public required IEnumerable<Chat> Chats { get; init; }
    
    public sealed class Chat
    {
        public required int Id { get; init; }
        public required int Type { get; init; }
        public required string Name { get; init; }
    }
}