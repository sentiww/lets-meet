namespace LetsMeet.WebAPI.Options;

internal sealed class JwtOptions
{
    public const string SectionName = "Jwt";
    public string SecurityKey { get; set; }
    public string ValidIssuer { get; set; }
    public string ValidAudience { get; set; }
    public int ExpiryInMinutes { get; set; }
}