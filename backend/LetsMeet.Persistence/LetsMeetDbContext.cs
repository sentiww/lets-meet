using LetsMeet.Persistence.Entities;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.Persistence;

public sealed class LetsMeetDbContext : DbContext
{
    public DbSet<UserEntity> Users { get; set; }
    public DbSet<FriendEntity> Friends { get; set; }
    public DbSet<BlobEntity> Blobs { get; set; }
    
    public LetsMeetDbContext(DbContextOptions<LetsMeetDbContext> options) : base(options)
    {
    }
}