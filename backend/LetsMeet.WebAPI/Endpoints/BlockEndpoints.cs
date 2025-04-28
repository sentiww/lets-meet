using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

internal static class BlockEndpoints
{
    public static IEndpointRouteBuilder MapBlockEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var userGroup = routeBuilder.MapGroup("block/{userId:int}")
            .RequireAuthorization();
        
        userGroup.MapPost(string.Empty, BlockEndpointHandler);
        userGroup.MapDelete(string.Empty, UnblockEndpointHandler);

        return routeBuilder;
    }

    private static async Task<Results<NotFound, NoContent>> UnblockEndpointHandler(
        int userId,
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken)
    {
        var block = await context.Blocks.FirstOrDefaultAsync(b => 
            b.UserId == userResolver.CurrentUser.Id && b.BlockedUserId == userId, cancellationToken);

        if (block is null)
        {
            return TypedResults.NotFound();
        }
        
        context.Remove(block);
        await context.SaveChangesAsync(cancellationToken);

        return TypedResults.NoContent();
    }

    private static async Task<Results<NotFound, BadRequest, NoContent>> BlockEndpointHandler(
        int userId,
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == userId, cancellationToken);

        if (user is null)
        {
            return TypedResults.NotFound();
        }

        if (user.Id == userResolver.CurrentUser.Id)
        {
            return TypedResults.BadRequest();
        }

        var isAlreadyBlocked = await context.Blocks.AnyAsync(b =>
            b.UserId == userResolver.CurrentUser.Id && b.BlockedUserId == userId, cancellationToken);

        if (isAlreadyBlocked)
        {
            return TypedResults.NoContent();
        }
        
        var block = new BlockEntity
        {
            UserId = userResolver.CurrentUser.Id,
            BlockedUserId = userId
        };

        context.Add(block);
        await context.SaveChangesAsync(cancellationToken);

        return TypedResults.NoContent();
    }
}