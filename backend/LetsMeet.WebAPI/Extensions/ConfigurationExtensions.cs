namespace LetsMeet.WebAPI.Extensions;

public static class ConfigurationExtensions
{
    public static TValue GetRequiredValue<TValue>(this IConfiguration configuration, string key)
    {
        var value = configuration.GetValue<TValue?>(key);

        if (value is null)
        {
            throw new InvalidOperationException($"Configuration value for key '{key}' is required.");
        }

        return value;
    }
}