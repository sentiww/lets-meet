namespace LetsMeet.Persistence.Entities;

public enum FriendStatus
{
    Pending,
    Accepted,
    Rejected
}

public class FriendEntity : BaseEntity
{
    public required UserEntity User { get; set; }
    public required UserEntity Friend { get; set; }
    public FriendStatus Status { get; set; }
}