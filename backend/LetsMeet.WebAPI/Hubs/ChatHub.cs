using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Services.ChatService;
using Microsoft.AspNetCore.SignalR;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Hubs;

public sealed class ChatHub : Hub, IChatSubscriber
{
    private readonly LetsMeetDbContext _context;
    private readonly IChatService _chatService;

    public ChatHub(
        LetsMeetDbContext context, 
        IChatService chatService)
    {
        _chatService = chatService;
        _context = context;
        
        _chatService.Subscribe(this);
    }

    public async Task SendMessage(
        int chatId, 
        int fromId, 
        string content, 
        CancellationToken cancellationToken = default)
    {
        var chat = await _context.Chats
            .Include(chat => chat.Users)
            .FirstOrDefaultAsync(c => c.Id == chatId && c.Users.Any(u => u.Id == fromId), cancellationToken);

        if (chat is null)
        {
            throw new Exception(); // TODO
        }

        var message = new MessageEntity
        {
            FromId = fromId,
            Content = content,
            SentAt = DateTime.UtcNow
        };

        await _chatService.SendAsync(chat, message, cancellationToken);
    }
    
    public async Task UpdateAsync(
        ChatEntity chat, 
        MessageEntity message, 
        CancellationToken cancellationToken = default)
    {
        await Clients.All.SendAsync("NewMessage", chat.Id, message.Id, cancellationToken);
    }
}