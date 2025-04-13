namespace LetsMeet.WebAPI.Services.TokenService;

internal readonly struct AccessToken : IParsable<AccessToken>
{
    public static readonly AccessToken Default = new();
    
    private readonly string? _value;

    public AccessToken()
    {
        _value = null;
    }

    public AccessToken(string token)
    {
        _value = token;
    }
    
    public static AccessToken Parse(string value, IFormatProvider? provider)
    {
        if (!TryParse(value, provider, out var result))
        {
            throw new ArgumentException("Could not parse supplied value.", nameof(value));
        }

        return result;
    }

    public static bool TryParse(string? value, IFormatProvider? provider, out AccessToken result)
    {
        var segments = value?.Split(' ', StringSplitOptions.RemoveEmptyEntries | StringSplitOptions.TrimEntries);
        
        if (segments?.Length == 2 && 
            string.Equals("Bearer", segments[0], StringComparison.OrdinalIgnoreCase))
        {
            result = new AccessToken(segments[1]);
            return true;
        }

        result = Default;
        return false;
    }

    public override string ToString() => _value ?? string.Empty;
}