using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using LetsMeet.Persistence.Entities;
using Microsoft.IdentityModel.Tokens;

namespace LetsMeet.WebAPI.Services.TokenService;

internal interface ITokenService
{
    public SigningCredentials GetSigningCredentials();
    public Task<IEnumerable<Claim>> GetClaimsAsync(UserEntity user);
    public JwtSecurityToken GenerateTokenOptions(SigningCredentials signingCredentials, IEnumerable<Claim> claims);
    public string GenerateRefreshToken();
    public ClaimsPrincipal GetPrincipalFromExpiredToken(string token);
}