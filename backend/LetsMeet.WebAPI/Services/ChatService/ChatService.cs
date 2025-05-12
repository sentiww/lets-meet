using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;

namespace LetsMeet.WebAPI.Services.ChatService;

public sealed class ChatService : IChatService
{
    private readonly IServiceProvider _serviceProvider;
    private readonly HashSet<IChatSubscriber> _subscribers;
    
    public ChatService(
        IServiceProvider serviceProvider)
    {
        _serviceProvider = serviceProvider;
        _subscribers = new HashSet<IChatSubscriber>();
    }

    public void Subscribe(IChatSubscriber subscriber) => _subscribers.Add(subscriber);

    public async Task SendAsync(
        ChatEntity chat,
        MessageEntity message, 
        CancellationToken cancellationToken = default)
    {
        await using var context = _serviceProvider.GetRequiredService<LetsMeetDbContext>();
        
        context.Messages.Add(message);
        
        await context.SaveChangesAsync(cancellationToken);

        try
        {
            await NotifySubscribersAsync(chat, message, cancellationToken);
        }
        catch
        {
            // Nothing, if it fails it fails
        }
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