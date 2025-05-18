using System.IdentityModel.Tokens.Jwt;
using System.Runtime.CompilerServices;
using System.Security.Claims;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Constants;

namespace LetsMeet.WebAPI.Services.UserService;

internal sealed class UserService : IUserService
{
    public async IAsyncEnumerable<Claim> GetClaimsAsync(
        UserEntity user, 
        [EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        yield return new(CustomClaimNames.Oid, user.Id.ToString());
        yield return new(JwtRegisteredClaimNames.UniqueName, user.Username);
        yield return new(JwtRegisteredClaimNames.GivenName, user.Name);
        yield return new(JwtRegisteredClaimNames.FamilyName, user.Surname);
        yield return new(JwtRegisteredClaimNames.Birthdate, user.DateOfBirth.ToString("yyyy-MM-dd'T'HH:mm:ss.fffK"));
        yield return new(JwtRegisteredClaimNames.Email, user.Email);
        yield return new(CustomClaimNames.IsAdmin, user.IsAdmin.ToString());
        yield return new(CustomClaimNames.IsBanned, user.IsBanned.ToString());
    }
}

internal sealed class UserData
{
    public required int Id { get; init; }
    public required string Username { get; init; }
    public required string Name { get; init; }
    public required string Surname { get; init; }
    public required string DateOfBirth { get; init; }
    public required string Email { get; init; }

    public required bool IsAdmin { get; init; }
    public required bool IsBanned { get; init; }
}