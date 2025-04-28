using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Contracts.Requests;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

internal static class FriendEndpoints
{
    public static IEndpointRouteBuilder MapFriendEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var userGroup = routeBuilder.MapGroup("friends")
            .RequireAuthorization();
        
        userGroup.MapPost("invite", FriendInviteEndpointHandler);
        userGroup.MapPost("accept", FriendAcceptEndpointHandler);
        userGroup.MapPost("reject", FriendRejectEndpointHandler);

        return routeBuilder;
    }

    private static async Task<Results<Ok, NotFound, Conflict<InviteFriendResponse>>> FriendInviteEndpointHandler(
        [FromBody] InviteFriendRequest request,
        [FromServices] LetsMeetDbContext context,
        [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var invitee = await context.Users.FirstOrDefaultAsync(
            u => u.Id == request.InviteeId,
            cancellationToken);

        if (invitee is null)
        {
            return TypedResults.NotFound();
        }

        var existingInvite = await context.Friends.FirstOrDefaultAsync(
            f => f.User.Id == userResolver.CurrentUser.Id && f.Friend.Id == invitee.Id, 
            cancellationToken);

        if (existingInvite is not null)
        {
            var response = new InviteFriendResponse
            {
                Status = existingInvite.Status.ToString()
            };
            return TypedResults.Conflict(response);
        }
        
        var inviter = await context.Users.FirstAsync(
            u => u.Id == userResolver.CurrentUser.Id,
            cancellationToken);

        var newFriend = new FriendEntity
        {
            User = inviter,
            Friend = invitee,
            Status = FriendStatus.Pending
        };
        
        context.Friends.Add(newFriend);
        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok();
    }
    
    private static async Task<Results<Ok, NotFound, Conflict<AcceptFriendResponse>>> FriendAcceptEndpointHandler(
        [FromBody] AcceptFriendRequest request,
        [FromServices] LetsMeetDbContext context,
        [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var invite = await context.Friends.FirstOrDefaultAsync(
            i => i.User.Id == userResolver.CurrentUser.Id && i.Friend.Id == request.InviteeId,
            cancellationToken);

        if (invite is null)
        {
            return TypedResults.NotFound();
        }

        if (invite.Status == FriendStatus.Accepted)
        {
            var response = new AcceptFriendResponse
            {
                Status = invite.Status.ToString()
            };
            return TypedResults.Conflict(response);
        }
        
        invite.Status = FriendStatus.Accepted;
        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok();
    }
    
    private static async Task<Results<Ok, NotFound, Conflict<RejectFriendResponse>>> FriendRejectEndpointHandler(
        [FromBody] RejectFriendRequest request,
        [FromServices] LetsMeetDbContext context,
        [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var invite = await context.Friends.FirstOrDefaultAsync(
            i => i.User.Id == userResolver.CurrentUser.Id && i.Friend.Id == request.InviteeId,
            cancellationToken);

        if (invite is null)
        {
            return TypedResults.NotFound();
        }

        if (invite.Status != FriendStatus.Pending)
        {
            var response = new RejectFriendResponse
            {
                Status = invite.Status.ToString()
            };
            return TypedResults.Conflict(response);
        }
        
        invite.Status = FriendStatus.Rejected;
        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok();
    }
}
