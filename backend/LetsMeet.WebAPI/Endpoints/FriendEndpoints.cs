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

        userGroup.MapGet(string.Empty, GetFriendsEndpointHandler);
        userGroup.MapGet("invites", GetInvitesEndpointHandler);
        userGroup.MapPost("invites", FriendInviteEndpointHandler);
        userGroup.MapPost("accept", FriendAcceptEndpointHandler);
        userGroup.MapPost("reject", FriendRejectEndpointHandler);
        userGroup.MapPost("remove", FriendRemoveEndpointHandler);

        return routeBuilder;
    }

    private static async Task<Ok<GetFriendsResponse>> GetFriendsEndpointHandler(
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var friends = await context.Friends
            .Where(f => (f.User.Id == userResolver.CurrentUser.Id || f.Friend.Id == userResolver.CurrentUser.Id) && f.Status == FriendStatus.Accepted)
            .Select(f => new GetFriendsResponse.Friend
            {
                Id = f.Id,
                FriendId = f.Friend.Id,
                UserId = f.User.Id
            })
            .ToListAsync(cancellationToken);

        return TypedResults.Ok(new GetFriendsResponse
        {
            Friends = friends
        });
    }

    private static async Task<Ok<GetInvitesResponse>> GetInvitesEndpointHandler(
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var invites = await context.Friends
            .Where(f => (f.User.Id == userResolver.CurrentUser.Id || f.Friend.Id == userResolver.CurrentUser.Id) && f.Status == FriendStatus.Pending)
            .Select(f => new GetInvitesResponse.Invite
            {
                Id = f.Id,
                FriendId = f.Friend.Id,
                UserId = f.User.Id
            })
            .ToListAsync(cancellationToken);

        return TypedResults.Ok(new GetInvitesResponse
        {
            Invites = invites
        });
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
            f => 
                (f.User.Id == userResolver.CurrentUser.Id && f.Friend.Id == invitee.Id) ||
                (f.User.Id == invitee.Id && f.Friend.Id == userResolver.CurrentUser.Id), 
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
        var invite = await context.Friends
            .Include(friendEntity => friendEntity.User)
            .Include(friendEntity => friendEntity.Friend)
            .FirstOrDefaultAsync(i => i.User.Id == request.InviteeId && i.Friend.Id == userResolver.CurrentUser.Id, cancellationToken);

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

        var chat = new ChatEntity
        {
            Name = $"{userResolver.CurrentUser.Name} - {invite.User.Name}",
            Type = ChatType.Direct,
            Users = await context.Users
                .Where(u => u.Id == invite.User.Id || u.Id == invite.Friend.Id)
                .ToListAsync(cancellationToken)
        };
        context.Add(chat);
        
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
            i => i.User.Id == request.InviteeId && i.Friend.Id == userResolver.CurrentUser.Id,
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

    private static async Task<Results<Ok, NotFound, Conflict<RemoveFriendResponse>>> FriendRemoveEndpointHandler(
        [FromBody] RemoveFriendRequest request,
        [FromServices] LetsMeetDbContext context,
        [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var friendship = await context.Friends.FirstOrDefaultAsync(
            f => 
                (f.User.Id == userResolver.CurrentUser.Id && f.Friend.Id == request.FriendId) ||
                (f.User.Id == request.FriendId && f.Friend.Id == userResolver.CurrentUser.Id),
            cancellationToken);

        if (friendship is null)
        {
            return TypedResults.NotFound();
        }

        if (friendship.Status != FriendStatus.Accepted)
        {
            var response = new RemoveFriendResponse
            {
                Status = friendship.Status.ToString()
            };
            return TypedResults.Conflict(response);
        }

        context.Friends.Remove(friendship);
        await context.SaveChangesAsync(cancellationToken);

        return TypedResults.Ok();
    }
}
