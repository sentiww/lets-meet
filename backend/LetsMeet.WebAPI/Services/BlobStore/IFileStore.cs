using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Services.BlobStore;

internal sealed class Blob
{
    public BlobMetadata Metadata { get; init; }
    public byte[] Data { get; init; }
}

internal sealed class BlobMetadata
{
    public int Id { get; set; }
    public int? OwnerId { get; init; }
    public string Name { get; init; }
    public string Extension { get; init; }
    public string ContentType { get; init; }
}

internal interface IBlobStore
{
    public Task SetAsync(Blob blob, CancellationToken cancellationToken = default);
    public Task<Blob> GetAsync(int blobId, CancellationToken cancellationToken = default);
    public Task RemoveAsync(int blobId, CancellationToken cancellationToken = default);
    public Task<IEnumerable<BlobMetadata>> GetAllAsync(CancellationToken cancellationToken = default);
}

internal sealed class DatabaseBlobStore : IBlobStore
{
    private readonly LetsMeetDbContext _context;
    private readonly IUserResolver _userResolver;
    
    public DatabaseBlobStore(
        LetsMeetDbContext context, 
        IUserResolver userResolver)
    {
        _context = context;
        _userResolver = userResolver;
    }

    public async Task SetAsync(Blob blob, CancellationToken cancellationToken = default)
    {
        // TODO: Separate context for blob writes
        if (_context.ChangeTracker.HasChanges())
        {
            throw new NotSupportedException();
        }

        var blobEntity = new BlobEntity
        {
            OwnerId = _userResolver.CurrentUser.Id,
            Name = blob.Metadata.Name,
            Extension = blob.Metadata.Extension,
            ContentType = blob.Metadata.ContentType,
            Data = blob.Data
        };
        
        _context.Blobs.Add(blobEntity);
        
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task<Blob> GetAsync(int blobId, CancellationToken cancellationToken = default)
    {
        var blob = await _context.Blobs.FirstOrDefaultAsync(b => b.Id == blobId && 
                                                                 b.OwnerId == _userResolver.CurrentUser.Id, cancellationToken);

        return new Blob
        {
            Metadata = new BlobMetadata
            {
                Id = blob.Id,
                OwnerId = blob.OwnerId,
                Name = blob.Name,
                Extension = blob.Extension,
                ContentType = blob.ContentType
            },
            Data = blob.Data
        };
    }

    public async Task RemoveAsync(int blobId, CancellationToken cancellationToken = default)
    {
        // TODO: Separate context for blob writes
        if (_context.ChangeTracker.HasChanges())
        {
            throw new NotSupportedException();
        }

        var ownerId = _userResolver.CurrentUser.Id;
        var blob = await _context.Blobs.FirstOrDefaultAsync(b => b.Id == blobId && b.OwnerId == ownerId, cancellationToken);

        if (blob is null)
        {
            return;
        }

        _context.Remove(blob);
        
        await _context.SaveChangesAsync(cancellationToken);
    }

    public async Task<IEnumerable<BlobMetadata>> GetAllAsync(CancellationToken cancellationToken = default)
    {
        var ownerId = _userResolver.CurrentUser.Id;

        return await _context.Blobs
            .Where(b => b.OwnerId == ownerId)
            .Select(b => new BlobMetadata
            {
                Id = b.Id,
                OwnerId = b.OwnerId,
                Name = b.Name,
                Extension = b.Extension,
                ContentType = b.ContentType
            })
            .ToListAsync(cancellationToken);
    }
}