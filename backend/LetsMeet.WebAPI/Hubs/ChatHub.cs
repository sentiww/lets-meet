using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Services.ChatService;
using Microsoft.AspNetCore.SignalR;

namespace LetsMeet.WebAPI.Hubs;

public sealed class ChatHub : Hub, IChatSubscriber
{
    public Task UpdateAsync(ChatEntity chat, MessageEntity message, CancellationToken cancellationToken = default)
    {
        var userIds = chat.Users.Select(u => u.Id.ToString());
        var users = Clients.Users(userIds);
        return users.SendAsync("NewMessage", message.Id, message.Content, message.FromId, message.SentAt, cancellationToken);
    }
}