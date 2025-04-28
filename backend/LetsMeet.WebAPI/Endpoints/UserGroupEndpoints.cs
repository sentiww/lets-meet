using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Contracts.Requests;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

internal static class UserGroupEndpoints
{
    public static IEndpointRouteBuilder MapUserGroupEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var UserGroupGroup = routeBuilder.MapGroup("userGroup")
            .RequireAuthorization();

        UserGroupGroup.MapGet(string.Empty, GetUserGroupsEndpointHandler);
        UserGroupGroup.MapGet("{UserGroupId:int}", GetUserGroupEndpointHandler);
        UserGroupGroup.MapPost(string.Empty, PostUserGroupEndpointHandler);
        UserGroupGroup.MapPut("{UserGroupId:int}", PutUserGroupEndpointHandler);
        UserGroupGroup.MapDelete("{UserGroupId:int}", DeleteUserGroupEndpointHandler);

        
        return routeBuilder;
    }

//delete by the owner
 private static async Task<Results<NoContent, NotFound, ForbidHttpResult>> DeleteUserGroupEndpointHandler(
        int UserGroupId,
        [FromServices] LetsMeetDbContext dbContext,
            [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var UserGroupEntity = await dbContext.UserGroups
            .FirstOrDefaultAsync(e => e.Id == UserGroupId, cancellationToken);

        if (UserGroupEntity is null)
        {
            return TypedResults.NotFound();
        }

        if(userResolver.CurrentUser.Id != UserGroupEntity.CreatedByUserId)
        {
            return TypedResults.Forbid();
        }

        dbContext.UserGroups.Remove(UserGroupEntity);
        await dbContext.SaveChangesAsync(cancellationToken);

        return TypedResults.NoContent();
    }

 private static async Task<Ok<GetUserGroupsResponse>> GetUserGroupsEndpointHandler(
        [FromServices] LetsMeetDbContext dbContext,
        CancellationToken cancellationToken)
    {
        var userGroups = await dbContext.UserGroups
            .Select(ug => new UserGroup
            {
                Id = ug.Id,
                Name = ug.Name
            })
            .ToListAsync(cancellationToken);

        var response = new GetUserGroupsResponse
        {
            UserGroups = userGroups
        };

        return TypedResults.Ok(response);
    }

    private static async Task<Results<NotFound, Ok<GetUserGroupResponse>>> GetUserGroupEndpointHandler(
        int userGroupId,
        [FromServices] LetsMeetDbContext dbContext,
        CancellationToken cancellationToken)
    {
        var userGroupEntity = await dbContext.UserGroups
            .FirstOrDefaultAsync(ug => ug.Id == userGroupId, cancellationToken);

        if (userGroupEntity is null)
        {
            return TypedResults.NotFound();
        }

        var response = new GetUserGroupResponse
        {
            Id = userGroupEntity.Id,
            Name = userGroupEntity.Name,
            Topic = userGroupEntity.Topic,
            CreatedByUserId = userGroupEntity.CreatedByUserId,
            CreatedAt = userGroupEntity.CreatedAt
        };

        return TypedResults.Ok(response);
    }

    private static async Task<Ok> PostUserGroupEndpointHandler(
        [FromBody] PostUserGroupRequest request,
        [FromServices] LetsMeetDbContext dbContext,
        [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var userGroupEntity = new UserGroupEntity
        {
            Name = request.Name,
            Topic = request.Topic,
            CreatedByUserId = userResolver.CurrentUser.Id,
            CreatedAt = DateTime.UtcNow
        };

        dbContext.UserGroups.Add(userGroupEntity);
        await dbContext.SaveChangesAsync(cancellationToken);

        return TypedResults.Ok();
    }

    private static async Task<Results<NotFound, Ok, ForbidHttpResult>> PutUserGroupEndpointHandler(
        int userGroupId,
        [FromBody] PostUserGroupRequest request,
        [FromServices] LetsMeetDbContext dbContext,
        [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var userGroupEntity = await dbContext.UserGroups
            .FirstOrDefaultAsync(ug => ug.Id == userGroupId, cancellationToken);

        if (userGroupEntity is null)
        {
            return TypedResults.NotFound();
        }

        if (userGroupEntity.CreatedByUserId != userResolver.CurrentUser.Id)
        {
            return TypedResults.Forbid();
        }

        userGroupEntity.Name = request.Name;
        userGroupEntity.Topic = request.Topic;

        await dbContext.SaveChangesAsync(cancellationToken);

        return TypedResults.Ok();
    }

}
