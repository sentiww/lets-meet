using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

public static class FeedEndpoints
{
    public static IEndpointRouteBuilder MapFeedEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var feedGroup = routeBuilder.MapGroup("feed");

        feedGroup.MapGet(string.Empty, GetFeedEndpointHandler);
        feedGroup.MapGet("liked", GetLikedEventsEndpointHandler);
        feedGroup.MapPost("{eventId:int}", LikeEndpointHandler);

        return routeBuilder;
    }

    private static async Task<Ok<GetLikedEventsResponse>> GetLikedEventsEndpointHandler(
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var events = await context.Events
            .Where(e => e.Participants.Any(ep => ep.UserId == userResolver.CurrentUser.Id))
            .Select(e => new GetLikedEventsResponse.Event
            {
                EventId = e.Id
            })
            .ToListAsync(cancellationToken);

        return TypedResults.Ok(new GetLikedEventsResponse
        {
            Events = events
        });
    }

    private static async Task<Results<NotFound, NoContent>> LikeEndpointHandler(
        int eventId,
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var eventExists = await context.Events.AnyAsync(e => e.Id == eventId, cancellationToken);

        if (eventExists is false)
        {
            return TypedResults.NotFound();
        }

        var participant = new EventParticipantEntity
        {
            UserId = userResolver.CurrentUser.Id,
            EventId = @eventId
        };
        context.Add(participant);
        await context.SaveChangesAsync(cancellationToken);

        return TypedResults.NoContent();
    }

    private static async Task<Results<Ok<GetFeedResponse>, NoContent>> GetFeedEndpointHandler(
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var possibleEventIds = await context.Events
            .Where(e => e.UserId != userResolver.CurrentUser.Id && e.Participants.Any(u => u.UserId == userResolver.CurrentUser.Id) == false)
            .Select(e => e.Id)
            .ToListAsync(cancellationToken);
        
        if (possibleEventIds.Count == 0)
        {
            return TypedResults.NoContent();
        }
        
        var randomEventId = possibleEventIds[Random.Shared.Next(0, possibleEventIds.Count)];

        var randomEvent = await context.Events
            .Select(e => new GetFeedResponse
            {
                EventId = e.Id,
                Title = e.Title,
                Description = e.Description,
                CreatedBy = e.UserId,
                PhotoIds = e.Photos.Select(ep => ep.BlobId),
                ParticipantIds = e.Participants.Select(p => p.UserId)
            })
            .FirstOrDefaultAsync(e => e.EventId == randomEventId, cancellationToken);

        return TypedResults.Ok(randomEvent);
    }
}