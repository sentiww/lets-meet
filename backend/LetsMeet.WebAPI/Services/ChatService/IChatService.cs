using LetsMeet.Persistence.Entities;

namespace LetsMeet.WebAPI.Services.ChatService;

public interface IChatService
{
    public void Subscribe(IChatSubscriber subscriber);
    public Task SendAsync(ChatEntity chat, MessageEntity message, CancellationToken cancellationToken = default);
}