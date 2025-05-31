using System.Text;
using LetsMeet.WebAPI.Contracts.Requests;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using LetsMeet.WebAPI.Services.BlobStore;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Blob = LetsMeet.WebAPI.Contracts.Responses.Blob;

namespace LetsMeet.WebAPI.Endpoints;

internal static class BlobEndpoints
{
    public static IEndpointRouteBuilder MapBlobEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var blobGroup = routeBuilder.MapGroup("blobs")
            .RequireAuthorization();

        blobGroup.MapGet(string.Empty, GetBlobsEndpointHandler);
        blobGroup.MapGet("{blobId:int}", GetBlobEndpointHandler);
        blobGroup.MapPost(string.Empty, PostBlobEndpointHandler);
        blobGroup.MapDelete("{blobId:int}", DeleteBlobEndpointHandler);

        return routeBuilder;
    }

    private static async Task DeleteBlobEndpointHandler(
        int blobId,
        [FromServices] IBlobStore blobStore,
        CancellationToken cancellationToken)
    {
        await blobStore.RemoveAsync(blobId, cancellationToken);
    }

    private static async Task<Ok<PostBlobResponse>> PostBlobEndpointHandler(
        [FromBody] PostBlobRequest request,
        [FromServices] IUserResolver userResolver,
        [FromServices] IBlobStore blobStore,
        CancellationToken cancellationToken)
    {
        var blob = new Services.BlobStore.Blob
        {
            Metadata = new BlobMetadata
            {
                OwnerId = userResolver.CurrentUser.Id, 
                Name = request.Name,
                Extension = request.Extension,
                ContentType = request.ContentType
            },
            Data = request.Data
        };
        var addedId = await blobStore.SetAsync(blob, cancellationToken);

        var response = new PostBlobResponse
        {
            NewBlob = new Blob
            {
                Id = addedId,
                Name = blob.Metadata.Name
            }
        };
        
        return TypedResults.Ok(response);
    }

    // private static async Task<Ok<GetBlobResponse>> GetBlobEndpointHandler(
    private static async Task<IFileHttpResult> GetBlobEndpointHandler(
        int blobId,
        HttpContext context,
        [FromServices] IBlobStore blobStore,
        CancellationToken cancellationToken)
    {
        var blob = await blobStore.GetAsync(blobId, cancellationToken);

        return TypedResults.File(blob.Data, blob.Metadata.ContentType, $"{blob.Metadata.Name}.{blob.Metadata.Extension}");
    }
    
    private static async Task<Ok<GetBlobsResponse>> GetBlobsEndpointHandler(
        [FromServices] IBlobStore blobStore,
        CancellationToken cancellationToken)
    {
        var blob = await blobStore.GetAllAsync(cancellationToken);

        var response = new GetBlobsResponse
        {
            Blobs = blob.Select(b => new Blob
            {
                Id = b.Id,
                Name = b.Name
            })
        };
        
        return TypedResults.Ok(response);
    }
}