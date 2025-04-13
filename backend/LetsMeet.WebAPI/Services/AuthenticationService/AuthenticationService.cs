using Microsoft.AspNetCore.Identity;

namespace LetsMeet.WebAPI.Services.AuthenticationService;

internal sealed class AuthenticationService : IAuthenticationService
{
    // This is just to wrap over PasswordHasher<TUser> API
    // default implementation doesn't use the TUser nor the user object.
    private readonly PasswordHasher<object> _passwordHasher = new();
    private readonly object? _user = null;
    
    public string HashPassword(string password) => _passwordHasher.HashPassword(_user, password);

    public bool VerifyHashedPassword(string hashedPassword, string providedPassword)
    {
        var result = _passwordHasher.VerifyHashedPassword(_user, hashedPassword, providedPassword);
        return result is PasswordVerificationResult.Success or PasswordVerificationResult.SuccessRehashNeeded;
    }
}