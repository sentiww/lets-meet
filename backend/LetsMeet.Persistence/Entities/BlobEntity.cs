namespace LetsMeet.Persistence.Entities;

public class BlobEntity : BaseEntity
{
    public int OwnerId { get; set; }
    public UserEntity Owner { get; set; }
    public string Name { get; set; }
    public string Extension { get; set; }
    public byte[] Stream { get; set; }
}