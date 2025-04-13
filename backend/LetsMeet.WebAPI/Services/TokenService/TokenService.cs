using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Security.Cryptography;
using System.Text;
using LetsMeet.WebAPI.Endpoints;
using LetsMeet.WebAPI.Options;
using Microsoft.Extensions.Options;
using Microsoft.IdentityModel.Tokens;

namespace LetsMeet.WebAPI.Services.TokenService;

internal sealed class TokenService : ITokenService
{
    private readonly JwtOptions _jwtOptions;
    private readonly JwtSecurityTokenHandler _jwtTokenHandler;
    private readonly TokenValidationParameters _tokenValidationParameters;
    private static readonly RandomNumberGenerator _randomNumberGenerator;
    private static readonly Encoding _keyEncoding;

    static TokenService()
    {
        _keyEncoding = Encoding.UTF8;
        _randomNumberGenerator = RandomNumberGenerator.Create();
    }
    
    public TokenService(
        IOptions<JwtOptions> jwtOptions, 
        JwtSecurityTokenHandler jwtTokenHandler)
    {
        _jwtOptions = jwtOptions.Value;
        _jwtTokenHandler = jwtTokenHandler;
        _tokenValidationParameters = new TokenValidationParameters
        {
            ValidateAudience = true,
            ValidateIssuer = true,
            ValidateIssuerSigningKey = true,
            IssuerSigningKey = new SymmetricSecurityKey(_keyEncoding.GetBytes(_jwtOptions.SecurityKey)),
            ValidateLifetime = false,
            ValidIssuer = _jwtOptions.ValidIssuer,
            ValidAudience = _jwtOptions.ValidAudience
        };
    }
    
    public SigningCredentials GetSigningCredentials()
    {
        var key = _keyEncoding.GetBytes(_jwtOptions.SecurityKey);
        var secret = new SymmetricSecurityKey(key);
        return new SigningCredentials(secret, SecurityAlgorithms.HmacSha256);
    }
    
    public JwtSecurityToken GenerateTokenOptions(SigningCredentials signingCredentials, IEnumerable<Claim> claims)
    {
        var tokenOptions = new JwtSecurityToken(
            issuer: _jwtOptions.ValidIssuer,
            audience: _jwtOptions.ValidAudience,
            claims: claims,
            expires: DateTime.Now.AddMinutes(Convert.ToDouble(_jwtOptions.ExpiryInMinutes)),
            signingCredentials: signingCredentials);
        return tokenOptions;
    }
    
    public ClaimsPrincipal GetPrincipalFromExpiredToken(AccessToken accessToken)
    {
        var principal = _jwtTokenHandler.ValidateToken(accessToken.ToString(), _tokenValidationParameters, out var securityToken);
        
        if (securityToken is not JwtSecurityToken jwtSecurityToken || 
            !jwtSecurityToken.Header.Alg.Equals(SecurityAlgorithms.HmacSha256, StringComparison.InvariantCultureIgnoreCase))
        {
            throw new SecurityTokenException("Invalid token");
        }
                
        return principal;
    }
}