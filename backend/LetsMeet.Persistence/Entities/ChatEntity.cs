namespace LetsMeet.Persistence.Entities;

public enum ChatType
{
    Direct,
    Group
}

public class ChatEntity : BaseEntity
{
    public string Name { get; set; }
    public ChatType Type { get; set; }
    public IEnumerable<UserEntity> Users { get; set; }
    public IEnumerable<MessageEntity> Messages { get; set; }
}