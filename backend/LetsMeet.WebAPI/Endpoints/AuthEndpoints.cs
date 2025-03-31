using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Contracts.Requests;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Services.AuthenticationService;
using LetsMeet.WebAPI.Services.TokenService;
using Microsoft.AspNetCore.Http.HttpResults;
using Microsoft.AspNetCore.Identity;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Endpoints;

internal static class AuthEndpoints
{
    public static IEndpointRouteBuilder MapAuthEndpoints(this IEndpointRouteBuilder routeBuilder)
    {
        var authGroup = routeBuilder.MapGroup("auth");

        authGroup.MapPost("signup", SignUpEndpointHandler);
        authGroup.MapPost("signin", SignInEndpointHandler);
        authGroup.MapPost("/token/refresh", RefreshTokenEndpointHandler);
        
        return authGroup;
    }

    private static async Task<Ok> SignUpEndpointHandler(
        [FromBody] SignUpRequest request,
        [FromServices] IAuthenticationService authenticationService,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        // TODO: Validation

        var passwordHash = new PasswordHasher<UserEntity>().HashPassword(null, request.Password);
        
        var user = new UserEntity
        {
            Username = request.Username,
            PasswordHash = passwordHash,
            Email = request.Email
        };
        
        context.Users.Add(user);
        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok();
    }

    private static async Task<Results<Ok<SignInResponse>, UnauthorizedHttpResult>> SignInEndpointHandler(
        [FromBody] SignInRequest request,
        [FromServices] ITokenService tokenService,
        [FromServices] IAuthenticationService authenticationService,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var user = await context.Users.FirstOrDefaultAsync(u => u.Username == request.Username, cancellationToken);
        
        if (user is null)
        {
            return TypedResults.Unauthorized();
        }
        
        var passwordVerificationResult = new PasswordHasher<UserEntity>().VerifyHashedPassword(
            null, user.PasswordHash, request.Password);
        
        if (passwordVerificationResult is PasswordVerificationResult.Failed)
        {
            return TypedResults.Unauthorized();
        }
        
        var claims = GetUserClaims(user);
            
        var signingCredentials = tokenService.GetSigningCredentials();
        var jwtOptions = tokenService.GenerateTokenOptions(signingCredentials, claims);
            
        var finalToken = new JwtSecurityTokenHandler().WriteToken(jwtOptions);
        var refreshToken = tokenService.GenerateRefreshToken();
            
        return TypedResults.Ok(new SignInResponse
        {
            Token = finalToken,
            RefreshToken = refreshToken
        });
    }

    private static async Task<Results<Ok<RefreshTokenResponse>, UnauthorizedHttpResult>> RefreshTokenEndpointHandler(
        [FromBody] RefreshTokenRequest request,
        [FromServices] ITokenService tokenService,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var principal = tokenService.GetPrincipalFromExpiredToken(request.Token);
        var username = principal.Identity?.Name;
        
        var user = await context.Users.FirstOrDefaultAsync(u => u.Username == username, cancellationToken);
            
        if (user is null || user.RefreshToken != request.Token || user.RefreshTokenExpirationDate <= DateTime.UtcNow)
        {
            return TypedResults.Unauthorized();
        }
        
        var claims = GetUserClaims(user);
        
        var signingCredentials = tokenService.GetSigningCredentials();
        var jwtOptions = tokenService.GenerateTokenOptions(signingCredentials, claims);
            
        var token = new JwtSecurityTokenHandler().WriteToken(jwtOptions);
        var refreshToken = tokenService.GenerateRefreshToken();
            
        return TypedResults.Ok(new RefreshTokenResponse
        {       
            Token = token,
            RefreshToken = refreshToken
        });
    }
    
    private static IEnumerable<Claim> GetUserClaims(UserEntity user) =>
        new Claim[]
        {
            new (JwtRegisteredClaimNames.UniqueName, user.Username),
            new (JwtRegisteredClaimNames.Email, user.Email)
        };
}