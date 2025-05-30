using System.Reflection;
using LetsMeet.Persistence.Entities;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.Persistence;

public sealed class LetsMeetDbContext : DbContext
{
    public DbSet<UserEntity> Users { get; set; }
    public DbSet<FriendEntity> Friends { get; set; }
    public DbSet<BlobEntity> Blobs { get; set; }
    public DbSet<BlockEntity> Blocks { get; set; }
    public DbSet<ChatEntity> Chats { get; set; }
    public DbSet<MessageEntity> Messages { get; set; }
    public DbSet<EventEntity> Events { get; set; }
    public DbSet<EventPhotoEntity> EventPhotos { get; set; }
    public DbSet<UserGroupEntity> UserGroups { get; set; }
    
    public LetsMeetDbContext(DbContextOptions<LetsMeetDbContext> options) : base(options)
    {
    }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
    }
}