namespace LetsMeet.WebAPI.Contracts.Responses;
public class GetEventPhotosResponse
{
    public IEnumerable<Photo> Photos { get; set; } = [];

    public class Photo
    {
        public int EventId { get; set; }
        public int BlobId { get; set; }
        public DateTime UploadedAt { get; set; }
    }
}
