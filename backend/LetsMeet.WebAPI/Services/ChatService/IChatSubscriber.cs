using LetsMeet.Persistence.Entities;

namespace LetsMeet.WebAPI.Services.ChatService;

public interface IChatSubscriber
{
    public Task UpdateAsync(ChatEntity chat, MessageEntity message, CancellationToken cancellationToken = default);
}