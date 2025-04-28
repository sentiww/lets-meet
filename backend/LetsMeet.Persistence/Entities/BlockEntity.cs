using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LetsMeet.Persistence.Entities;

public class BlockEntity : BaseEntity
{
    public UserEntity User { get; set; }
    public int UserId { get; set; }
    public UserEntity BlockedUser { get; set; }
    public int BlockedUserId { get; set; }
}

public sealed class BlockEntityConfiguration : IEntityTypeConfiguration<BlockEntity>
{
    public void Configure(EntityTypeBuilder<BlockEntity> builder)
    {
        builder.HasOne<UserEntity>(u => u.User)
            .WithMany(u => u.BlockedUsers)
            .HasForeignKey(u => u.UserId);
        
        builder.HasOne<UserEntity>(u => u.BlockedUser)
            .WithMany(u => u.BlockedByUsers)
            .HasForeignKey(u => u.BlockedUserId);
    }
}