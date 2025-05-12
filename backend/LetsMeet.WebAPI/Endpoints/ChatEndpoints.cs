using LetsMeet.Persistence;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Middlewares.UserResolver;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

internal static class ChatEndpoints
{
    public static IEndpointRouteBuilder MapChatEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var chatGroup = routeBuilder.MapGroup("chats");

        chatGroup.MapGet(string.Empty, GetChatsEndpointHandler);
        chatGroup.MapGet("{chatId:int}", GetChatEndpointHandler);
        chatGroup.MapGet("{chatId:int}/messages/{messageId:int}", GetChatMessageEndpointHandler);

        return routeBuilder;
    }

    private static async Task<Results<NotFound, Ok<GetChatMessageResponse>>> GetChatMessageEndpointHandler(
        int chatId,
        int messageId,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var message = await context.Messages
            .Select(m => new GetChatMessageResponse
            {
                Id = m.Id,
                FromId = m.FromId,
                SentAt = m.SentAt,
                Content = m.Content
            })
            .FirstOrDefaultAsync(m => m.Id == messageId, cancellationToken);

        if (message is null)
        {
            return TypedResults.NotFound();
        }

        return TypedResults.Ok(message);
    }

    private static async Task<Results<NotFound, ForbidHttpResult, Ok<GetChatResponse>>> GetChatEndpointHandler(
        int chatId,
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context)
    {
        var chat = await context.Chats
            .Select(c => new GetChatResponse
            {
                Id = c.Id,
                Type = (int)c.Type,
                Name = c.Name,
                UserIds = c.Users.Select(u => u.Id),
                Messages = c.Messages.Select(m => new GetChatResponse.Message
                {
                    Id = m.Id,
                    FromId = m.FromId,
                    SentAt = m.SentAt,
                    Content = m.Content
                })
            })
            .FirstOrDefaultAsync(c => c.Id == chatId);

        if (chat is null)
        {
            return TypedResults.NotFound();
        }

        if (chat.UserIds.Contains(userResolver.CurrentUser.Id) is false)
        {
            return TypedResults.Forbid();
        }

        return TypedResults.Ok(chat);
    }

    private static async Task<Ok<GetChatsResponse>> GetChatsEndpointHandler(
        [FromServices] IUserResolver userResolver,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var currentUserId = userResolver.CurrentUser.Id;
        
        var chats = await context.Chats
            .Where(c => c.Users.Any(u => u.Id == currentUserId))
            .Select(c => new GetChatsResponse.Chat
            {
                Id = c.Id,
                Type = (int)c.Type,
                Name = c.Name
            })
            .ToListAsync(cancellationToken);

        return TypedResults.Ok(new GetChatsResponse
        {
            Chats = chats
        });
    }
}