namespace LetsMeet.Persistence.Entities;

public class EventPhotoEntity : BaseEntity
{
    public int EventId { get; set; }
    public EventEntity Event { get; set; }

    public int BlobId { get; set; }
    public BlobEntity Blob { get; set; }

    public DateTime UploadedAt { get; set; }
}