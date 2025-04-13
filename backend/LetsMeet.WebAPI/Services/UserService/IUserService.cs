using System.Security.Claims;
using LetsMeet.Persistence.Entities;

namespace LetsMeet.WebAPI.Services.UserService;

internal interface IUserService
{
    public IAsyncEnumerable<Claim> GetClaimsAsync(
        UserEntity user,
        CancellationToken cancellationToken = default);
}