using System.Security.Claims;
using LetsMeet.WebAPI.Services.UserService;

namespace LetsMeet.WebAPI.Middlewares.UserResolver;

internal sealed class UserResolver : IUserResolver
{
    private UserData? _currentUser;
    public UserData CurrentUser
    {
        get
        {
            if (_currentUser is null)
            {
                throw new Exception($"{CurrentUser} could not be set in scope.");
            }
            
            return _currentUser;
        }
        set
        {
            if (_currentUser is not null)
            {
                throw new NotSupportedException($"{nameof(CurrentUser)} was already initialized.");
            }

            _currentUser = value;
        }
    }

    public void Bind(IEnumerable<Claim> claims)
    {
        const string oid = "http://schemas.microsoft.com/identity/claims/objectidentifier";

        var enumerable = claims.ToList();
        
        _currentUser = new UserData
        {
            Id = int.Parse(enumerable.First(c => c.Type == oid).Value),
            Username = enumerable.First(c => c.Type == ClaimTypes.Name).Value,
            Name = enumerable.First(c => c.Type == ClaimTypes.GivenName).Value,
            Surname = enumerable.First(c => c.Type == ClaimTypes.Surname).Value,
            DateOfBirth = enumerable.First(c => c.Type == ClaimTypes.DateOfBirth).Value,
            Email = enumerable.First(c => c.Type == ClaimTypes.Email).Value
        };
    }
}