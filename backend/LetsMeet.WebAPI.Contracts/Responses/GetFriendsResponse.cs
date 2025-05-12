namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetFriendsResponse
{
    public required IEnumerable<Friend> Friends { get; init; }
    
    public sealed class Friend
    {
        public required int Id { get; init; }
        public required int FriendId { get; init; }
        public required int UserId { get; init; }
    }
}