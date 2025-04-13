using System.Text;

namespace LetsMeet.WebAPI.Extensions;

public static class StringExtensions
{
    public static string ToFirstCharacterLower(this string @string)
    {
        ArgumentException.ThrowIfNullOrEmpty(@string);

        if (char.IsLower(@string[0]))
        {
            return @string;
        }

        var stringBuilder = new StringBuilder();
        
        stringBuilder.Append(char.ToLower(@string[0]));
        stringBuilder.Append(@string[1..]);
        
        return stringBuilder.ToString();
    }
}