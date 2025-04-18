namespace LetsMeet.Persistence.Entities;

public sealed class UserEntity : BaseEntity
{
    public string Username { get; set; }
    public string PasswordHash { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public string Email { get; set; }
    public DateTimeOffset DateOfBirth { get; set; }
    
    public string? RefreshToken { get; set; }
    public DateTime? RefreshTokenExpirationDate { get; set; }
    
    public IEnumerable<BlobEntity> Blobs { get; set; }
}