namespace LetsMeet.Persistence.Entities;


public class EventEntity : BaseEntity
{
    public int UserId { get; set; }
    public UserEntity User { get; set; }
    public string? Title { get; set; }
    public string? Description { get; set; }
    public DateTime EventDate { get; set; }
    public DateTime CreatedAt { get; set; }
    public DateTime UpdatedAt { get; set; }
    public IEnumerable<EventPhotoEntity> Photos { get; set; }
    public IEnumerable<EventParticipantEntity> Participants { get; set; }
}