using System.IdentityModel.Tokens.Jwt;
using LetsMeet.Persistence;
using LetsMeet.Persistence.Entities;
using LetsMeet.WebAPI.Contracts.Requests;
using LetsMeet.WebAPI.Contracts.Responses;
using LetsMeet.WebAPI.Services.AuthenticationService;
using LetsMeet.WebAPI.Services.TokenService;
using LetsMeet.WebAPI.Services.UserService;
using LetsMeet.WebAPI.Validators;
using Microsoft.AspNetCore.Http.HttpResults;
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
        authGroup.MapPost("token/refresh", RefreshTokenEndpointHandler)
            .RequireAuthorization();
        
        return routeBuilder;
    }

    private static async Task<Results<Ok, BadRequest<ValidationProblemDetails>>> SignUpEndpointHandler(
        [FromBody] SignUpRequest request,
        [FromServices] IApiValidator<SignUpRequest> validator,
        [FromServices] IAuthenticationService authenticationService,
        [FromServices] LetsMeetDbContext context,
        CancellationToken cancellationToken = default)
    {
        var validationResult = await validator.ValidateAsync(request, cancellationToken);

        if (validationResult.IsValid is false)
        {
            return TypedResults.BadRequest(ValidatorUtils.ToProblemDetails(validator, validationResult));
        }
        
        var passwordHash = authenticationService.HashPassword(request.Password);
        
        var user = new UserEntity
        {
            Username = request.Username,
            PasswordHash = passwordHash,
            Name = request.Name,
            Surname = request.Surname,
            DateOfBirth = request.DateOfBirth.UtcDateTime,
            Email = request.Email
        };
        
        context.Users.Add(user);
        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok();
    }

    private static async Task<Results<Ok<SignInResponse>, BadRequest<ValidationProblemDetails>, UnauthorizedHttpResult>> SignInEndpointHandler(
        [FromBody] SignInRequest request,
        [FromServices] IApiValidator<SignInRequest> validator,
        [FromServices] ITokenService tokenService,
        [FromServices] IAuthenticationService authenticationService,
        [FromServices] IUserService userService,
        [FromServices] JwtSecurityTokenHandler jwtTokenHandler,
        [FromServices] LetsMeetDbContext context,
        [FromServices] TimeProvider timeProvider,
        CancellationToken cancellationToken = default)
    {
        var validationResult = await validator.ValidateAsync(request, cancellationToken);

        if (validationResult.IsValid is false)
        {
            return TypedResults.BadRequest(ValidatorUtils.ToProblemDetails(validator, validationResult));
        }
        
        var user = await context.Users.FirstOrDefaultAsync(u => u.Username == request.Username, cancellationToken);
        
        if (user is null)
        {
            return TypedResults.Unauthorized();
        }
        
        var verified = authenticationService.VerifyHashedPassword(user.PasswordHash, request.Password);
        
        if (verified is false)
        {
            return TypedResults.Unauthorized();
        }
        
        var claims = await userService.GetClaimsAsync(user, cancellationToken).ToListAsync(cancellationToken);
            
        var signingCredentials = tokenService.GetSigningCredentials();
        var jwtOptions = tokenService.GenerateTokenOptions(signingCredentials, claims);
            
        var finalToken = jwtTokenHandler.WriteToken(jwtOptions);
        var refreshToken = RefreshToken.NewRefreshToken().ToString();

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpirationDate = timeProvider.GetUtcNow().UtcDateTime.AddMinutes(10);

        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok(new SignInResponse
        {
            Token = finalToken,
            RefreshToken = refreshToken
        });
    }

    private static async Task<Results<Ok<RefreshTokenResponse>, UnauthorizedHttpResult, BadRequest<ValidationProblemDetails>>> RefreshTokenEndpointHandler(
        [FromHeader(Name = "Authorization")] AccessToken accessToken,
        [FromBody] RefreshTokenRequest request,
        [FromServices] IApiValidator<RefreshTokenRequest> validator,
        [FromServices] ITokenService tokenService,
        [FromServices] IUserService userService,
        [FromServices] JwtSecurityTokenHandler jwtTokenHandler,
        [FromServices] LetsMeetDbContext context,
        [FromServices] TimeProvider timeProvider,
        CancellationToken cancellationToken = default)
    {
        var validationResult = await validator.ValidateAsync(request, cancellationToken);

        if (validationResult.IsValid is false)
        {
            return TypedResults.BadRequest(ValidatorUtils.ToProblemDetails(validator, validationResult));
        }

        var utcNow = timeProvider.GetUtcNow().DateTime;
        
        var principal = tokenService.GetPrincipalFromExpiredToken(accessToken);
        var username = principal.Identity?.Name;
        
        var user = await context.Users.FirstOrDefaultAsync(u => u.Username == username, cancellationToken);
            
        if (user is null || user.RefreshToken != request.RefreshToken || user.RefreshTokenExpirationDate <= utcNow)
        {
            return TypedResults.Unauthorized();
        }
        
        var claims = await userService.GetClaimsAsync(user, cancellationToken).ToListAsync(cancellationToken);
        
        var signingCredentials = tokenService.GetSigningCredentials();
        var jwtOptions = tokenService.GenerateTokenOptions(signingCredentials, claims);
            
        var newToken = jwtTokenHandler.WriteToken(jwtOptions);
        var refreshToken = RefreshToken.NewRefreshToken().ToString();

        user.RefreshToken = refreshToken;
        user.RefreshTokenExpirationDate = utcNow.AddMinutes(10);

        await context.SaveChangesAsync(cancellationToken);
        
        return TypedResults.Ok(new RefreshTokenResponse
        {       
            Token = newToken,
            RefreshToken = refreshToken
        });
    }
}