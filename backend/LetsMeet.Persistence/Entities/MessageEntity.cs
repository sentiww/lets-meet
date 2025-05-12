namespace LetsMeet.Persistence.Entities;

public class MessageEntity : BaseEntity
{
    public int FromId { get; set; }
    public UserEntity From { get; set; }
    public string Content { get; set; }
    public DateTime SentAt { get; set; }
}