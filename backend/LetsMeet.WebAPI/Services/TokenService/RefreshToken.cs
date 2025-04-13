using System.Security.Cryptography;

namespace LetsMeet.WebAPI.Services.TokenService;

internal readonly struct RefreshToken
{
    private readonly string? _value;

    public RefreshToken()
    {
        _value = NewRefreshTokenCore();
    }

    public static RefreshToken NewRefreshToken() => new();
    
    public override string ToString() => _value;

    private static string NewRefreshTokenCore()
    {
        Span<byte> randomNumber = stackalloc byte[32];
        RandomNumberGenerator.Fill(randomNumber);
        return Convert.ToBase64String(randomNumber);
    }
}