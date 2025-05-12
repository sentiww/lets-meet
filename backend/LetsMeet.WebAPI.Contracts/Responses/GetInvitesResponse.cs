namespace LetsMeet.WebAPI.Contracts.Responses;

public sealed class GetInvitesResponse
{
    public required IEnumerable<Invite> Invites { get; init; }
    
    public sealed class Invite
    {
        public required int Id { get; init; }
        public required int FriendId { get; init; }
        public required int UserId { get; init; }
    }
}