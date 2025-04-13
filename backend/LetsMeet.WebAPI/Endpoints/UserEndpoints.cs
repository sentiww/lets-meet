using LetsMeet.Persistence;
using LetsMeet.WebAPI.Contracts.Requests;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

internal static class UserEndpoints
{
    public static IEndpointRouteBuilder MapUserEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var userGroup = routeBuilder.MapGroup("users")
            .RequireAuthorization();

        userGroup.MapGet("me", GetMeEndpointHandler);
        userGroup.MapPut("me", PutMeEndpointHandler);
        userGroup.MapGet("{id:int}", GetUserEndpointHandler);
        
        return routeBuilder;
    }

    private static async Task<Results<Ok<GetUserResponse>, NotFound>> GetUserEndpointHandler(
        int id,
        [FromServices] LetsMeetDbContext context)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Id == id);

        if (user is null)
        {
            return TypedResults.NotFound();
        }

        var response = new GetUserResponse
        {
            Id = user.Id,
            Username = user.Username
        };

        return TypedResults.Ok(response);
    }
    
    private static async Task<Ok> PutMeEndpointHandler(
        [FromBody] PutMeRequest request,
        [FromServices] LetsMeetDbContext context,
        [FromServices] IUserResolver userResolver,
        CancellationToken cancellationToken)
    {
        var user = await context.Users.FirstAsync(u => u.Id == userResolver.CurrentUser.Id, cancellationToken);

        user.Name = request.Name;
        user.Surname = request.Surname;
        user.DateOfBirth = request.DateOfBirth;
        user.Email = request.Email;

        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok();
    }
    
    private static async Task<Ok<GetMeResponse>> GetMeEndpointHandler(
        [FromServices] LetsMeetDbContext context,
        [FromServices] IUserResolver userResolver)
    {
        var user = await context.Users.FirstAsync(u => u.Id == userResolver.CurrentUser.Id);

        var response = new GetMeResponse
        {
            Id = user.Id,
            Username = user.Username,
            Name = user.Name,
            Surname = user.Surname,
            DateOfBirth = user.DateOfBirth,
            Email = user.Email
        };
        
        return TypedResults.Ok(response);
    }
}