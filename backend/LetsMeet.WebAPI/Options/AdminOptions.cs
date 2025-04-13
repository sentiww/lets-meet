namespace LetsMeet.WebAPI.Options;

internal sealed class AdminOptions
{
    public const string SectionName = "Admin";
    public bool EnsureExists { get; set; }
    public string Username { get; set; }
    public string Name { get; set; }
    public string Surname { get; set; }
    public DateTimeOffset DateOfBirth { get; set; }
    public string Email { get; set; }
    public string Password { get; set; }
}