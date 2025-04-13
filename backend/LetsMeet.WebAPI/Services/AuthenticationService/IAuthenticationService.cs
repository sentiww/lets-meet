namespace LetsMeet.WebAPI.Services.AuthenticationService;

internal interface IAuthenticationService
{
    public string HashPassword(string password);
    public bool VerifyHashedPassword(string hashedPassword, string providedPassword);
}