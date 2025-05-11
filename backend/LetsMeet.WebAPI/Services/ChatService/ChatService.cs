using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Hubs;
using Microsoft.AspNetCore.SignalR;

namespace LetsMeet.WebAPI.Services.ChatService;

public sealed class ChatService : IChatService
{
    private readonly LetsMeetDbContext _context;
    private readonly HashSet<IChatSubscriber> _subscribers;
    
    public ChatService(LetsMeetDbContext context)
    {
        _context = context;
        _subscribers = new HashSet<IChatSubscriber>();
    }

    public void Subscribe(IChatSubscriber subscriber) => _subscribers.Add(subscriber);

    public async Task SendAsync(
        ChatEntity chat,
        MessageEntity message, 
        CancellationToken cancellationToken = default)
    {
        _context.Messages.Add(message);

        try
        {
            await NotifySubscribersAsync(chat, message, cancellationToken);
        }
        catch
        {
            // Nothing, fire and forget
        }
        
        await _context.SaveChangesAsync(cancellationToken);
    }

    private async Task NotifySubscribersAsync(
        ChatEntity chat,
        MessageEntity message, 
        CancellationToken cancellationToken = default)
    {
        var subscriberTasks = new List<Task>(_subscribers.Count);

        foreach (var subscriber in _subscribers) 
        { 
            subscriberTasks.Add(subscriber.UpdateAsync(chat, message, cancellationToken));
        }
            
        await Task.WhenAll(subscriberTasks);
    }
}