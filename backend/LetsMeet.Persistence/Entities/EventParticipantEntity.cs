namespace LetsMeet.Persistence.Entities;

public sealed class EventParticipantEntity : BaseEntity
{
    public int UserId { get; set; }
    public UserEntity User { get; set; }
    public int EventId { get; set; }
    public EventEntity Event { get; set; }
}