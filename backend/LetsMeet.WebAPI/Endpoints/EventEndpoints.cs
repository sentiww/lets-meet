using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

internal static class EventEndpoints
{
    public static IEndpointRouteBuilder MapEventEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var eventGroup = routeBuilder.MapGroup("events")
            .RequireAuthorization();

        eventGroup.MapGet(string.Empty, GetEventsEndpointHandler);
        eventGroup.MapGet("{eventId:int}", GetEventEndpointHandler);
        eventGroup.MapPost(string.Empty, PostEventEndpointHandler);
        eventGroup.MapPut("{eventId:int}", PutEventEndpointHandler);
        eventGroup.MapDelete("{eventId:int}", DeleteEventEndpointHandler);

        
        return routeBuilder;
    }

//delete by the owner
 private static async Task<Results<NoContent, NotFound, ForbidHttpResult>> DeleteEventEndpointHandler(
        int eventId,
        [FromServices] LetsMeetDbContext dbContext,
            [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var eventEntity = await dbContext.Events
            .FirstOrDefaultAsync(e => e.Id == eventId, cancellationToken);

        if (eventEntity is null)
        {
            return TypedResults.NotFound();
        }

        if(userResolver.CurrentUser.Id != eventEntity.UserId)
        {
            return TypedResults.Forbid();
        }

        dbContext.Events.Remove(eventEntity);
        await dbContext.SaveChangesAsync(cancellationToken);

        return TypedResults.NoContent();
    }

private static async Task<Ok<GetEventsResponse>> GetEventsEndpointHandler(
    [FromServices] LetsMeetDbContext dbContext,
    CancellationToken cancellationToken)
{
    var events = await dbContext.Events
        .Select(e => new GetEventsResponse.Event
        {
            Id = e.Id,
            Title = e.Title ?? string.Empty
        })
        .ToListAsync(cancellationToken);

    var response = new GetEventsResponse
    {
        Events = events
    };

    return TypedResults.Ok(response);
}

private static async Task<Results<NotFound, Ok<GetEventResponse>>> GetEventEndpointHandler(
    int eventId,
    [FromServices] LetsMeetDbContext dbContext,
    CancellationToken cancellationToken)
{
    var eventEntity = await dbContext.Events
        .Include(e => e.Photos) 
        .FirstOrDefaultAsync(e => e.Id == eventId, cancellationToken);

    if (eventEntity is null)
    {
        return TypedResults.NotFound();
    }

    var response = new GetEventResponse
    {
        Id = eventEntity.Id,
        Title = eventEntity.Title ?? string.Empty,
        Description = eventEntity.Description,
        EventDate = eventEntity.EventDate,
        PhotoIds = eventEntity.Photos.Select(p => p.Id)
    };

    return TypedResults.Ok(response);
}

private static async Task<Ok> PostEventEndpointHandler(
    [FromBody] PostEventRequest request,
    [FromServices] LetsMeetDbContext dbContext,
    [FromServices] IUserResolver userResolver,
    CancellationToken cancellationToken)
{
    var eventEntity = new EventEntity
    {
        Title = request.Title,
        Description = request.Description,
        EventDate = request.EventDate,
        CreatedAt = DateTime.UtcNow,
        UpdatedAt = DateTime.UtcNow,
        UserId = userResolver.CurrentUser.Id
    };

    dbContext.Events.Add(eventEntity);
    await dbContext.SaveChangesAsync(cancellationToken); // Save first to get EventId

    var eventPhotos = request.PhotoBlobIds.Select(blobId => new EventPhotoEntity
    {
        EventId = eventEntity.Id,
        BlobId = blobId,
        UploadedAt = DateTime.UtcNow
    }).ToList();

    dbContext.EventPhotos.AddRange(eventPhotos);
    await dbContext.SaveChangesAsync(cancellationToken);

    return TypedResults.Ok();
}

private static async Task<Results<NotFound, Ok>> PutEventEndpointHandler(
    int eventId,
    [FromBody] PostEventRequest request, 
    [FromServices] LetsMeetDbContext dbContext,
    [FromServices] IUserResolver userResolver,
    CancellationToken cancellationToken)
{
    var eventEntity = await dbContext.Events
        .Include(e => e.Photos)
        .FirstOrDefaultAsync(e => e.Id == eventId, cancellationToken);

    if (eventEntity is null)
    {
        return TypedResults.NotFound();
    }

    if (eventEntity.UserId != userResolver.CurrentUser.Id)
    {
        return TypedResults.NotFound(); // or return Forbid() if you prefer
    }

    eventEntity.Title = request.Title;
    eventEntity.Description = request.Description;
    eventEntity.EventDate = request.EventDate;
    eventEntity.UpdatedAt = DateTime.UtcNow;

    // Remove old photos
    dbContext.EventPhotos.RemoveRange(eventEntity.Photos);

    // Add new photos
    var newPhotos = request.PhotoBlobIds.Select(blobId => new EventPhotoEntity
    {
        EventId = eventEntity.Id,
        BlobId = blobId,
        UploadedAt = DateTime.UtcNow
    }).ToList();

    dbContext.EventPhotos.AddRange(newPhotos);

    await dbContext.SaveChangesAsync(cancellationToken);

    return TypedResults.Ok();
}

}
