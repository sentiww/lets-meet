namespace LetsMeet.Persistence.Entities;

public sealed class UserEntity : BaseEntity
{
    public string Username { get; set; }
    public string PasswordHash { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public string Email { get; set; }

    public Boolean isAdmin { get; set; }
    public Boolean isBanned { get; set; }
    public DateTime DateOfBirth { get; set; }
    
    public string? RefreshToken { get; set; }
    public DateTime? RefreshTokenExpirationDate { get; set; }
    
    public IEnumerable<BlobEntity> Blobs { get; set; }
    
    public IEnumerable<BlockEntity> BlockedUsers { get; set; }
    public IEnumerable<BlockEntity> BlockedByUsers { get; set; }
    
    public int? AvatarId { get; set; }
    public BlobEntity? Avatar { get; set; }
}