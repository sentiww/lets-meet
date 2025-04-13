using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using Microsoft.IdentityModel.Tokens;

namespace LetsMeet.WebAPI.Services.TokenService;

internal interface ITokenService
{
    public SigningCredentials GetSigningCredentials();
    public JwtSecurityToken GenerateTokenOptions(SigningCredentials signingCredentials, IEnumerable<Claim> claims);
    public ClaimsPrincipal GetPrincipalFromExpiredToken(AccessToken accessToken);
}