using System.IdentityModel.Tokens.Jwt;
using LetsMeet.Persistence;
using LetsMeet.WebAPI.Options;
using LetsMeet.WebAPI.Services.TokenService;
using LetsMeet.WebAPI.Services.UserService;
using Microsoft.Extensions.Options;
using Scalar.AspNetCore;
using ScalarApiOptions = Scalar.AspNetCore.ScalarOptions;
using ScalarOptions = LetsMeet.WebAPI.Options.ScalarOptions;

namespace LetsMeet.WebAPI.Extensions;

public static class ScalarOptionsExtensions
{
    public static ScalarApiOptions WithDefaultHttpBearerAuthentication(
        this ScalarApiOptions options, 
        HttpContext context)
    {
        var dbContext = context.RequestServices.GetRequiredService<LetsMeetDbContext>();
        var scalarOptions = context.RequestServices.GetRequiredService<IOptions<ScalarOptions>>();

        if (scalarOptions.Value.UseDefaultAuthentication is false)
        {
            return options;
        }
        
        var user = dbContext.Users.FirstOrDefault(u => u.Username == scalarOptions.Value.DefaultAuthentication!.Username);
        if (user is null)
        {
            throw new Exception("User not found.");
        }
        
        var userService = context.RequestServices.GetRequiredService<IUserService>();
        var tokenService = context.RequestServices.GetRequiredService<ITokenService>();
        var jwtTokenHandler = context.RequestServices.GetRequiredService<JwtSecurityTokenHandler>();
                
        var adminClaims = userService.GetClaimsAsync(user).ToListAsync().AsTask().GetAwaiter().GetResult();

        var signingCredentials = tokenService.GetSigningCredentials();
        var tokenData = tokenService.GenerateTokenOptions(signingCredentials, adminClaims);

        var token = jwtTokenHandler.WriteToken(tokenData);
        
        options.WithHttpBearerAuthentication(bearerOptions =>
        {
            bearerOptions.Token = token;
        });

        return options;
    }
}