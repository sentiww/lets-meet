using System.Security.Claims;
using LetsMeet.WebAPI.Services.UserService;

namespace LetsMeet.WebAPI.Middlewares.UserResolver;

internal interface IUserResolver
{
    public UserData CurrentUser { get; }

    internal void Bind(IEnumerable<Claim> claims);
}