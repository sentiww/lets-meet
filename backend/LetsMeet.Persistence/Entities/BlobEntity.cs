using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;

namespace LetsMeet.Persistence.Entities;

public class BlobEntity : BaseEntity
{
    public int? OwnerId { get; set; }
    public UserEntity? Owner { get; set; }
    public string Name { get; set; }
    public string Extension { get; set; }
    public string ContentType { get; set; }
    public byte[] Data { get; set; }
}

public sealed class BlobEntityConfiguration : IEntityTypeConfiguration<BlobEntity>
{
    public void Configure(EntityTypeBuilder<BlobEntity> builder)
    {
        builder.HasOne<UserEntity>(b => b.Owner)
            .WithMany(u => u.Blobs);
    }
}