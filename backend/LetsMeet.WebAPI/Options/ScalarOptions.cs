namespace LetsMeet.WebAPI.Options;

internal sealed class ScalarOptions
{
    public const string SectionName = "Scalar";
    
    public bool UseDefaultAuthentication { get; set; }
    public DefaultAuthenticationSection? DefaultAuthentication { get; set; }
    
    public class DefaultAuthenticationSection
    {
        public string Username { get; set; }
    }
}