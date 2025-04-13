using System.Net;
using FluentValidation.Results;
using LetsMeet.WebAPI.Extensions;
using Microsoft.AspNetCore.Mvc;

namespace LetsMeet.WebAPI.Validators;

internal static class ValidatorUtils
{
    public static ValidationProblemDetails ToProblemDetails<T>(
        IApiValidator<T> validator, 
        ValidationResult result)
    {
        const int status = (int)HttpStatusCode.BadRequest;

        return new ValidationProblemDetails
        {
            Title = validator.Title,
            Type = $"https://developer.mozilla.org/en-US/docs/Web/HTTP/Reference/Status/{status}",
            Errors = result.Errors.GroupBy(e => e.PropertyName)
                .ToDictionary(e => e.Key.ToFirstCharacterLower(), e => 
                    e.Select(vf => $"{vf.ErrorCode}: {vf.ErrorMessage}").ToArray()),
            Status = status,
            Extensions = new Dictionary<string, object?>
            {
                ["errorCodes"] = result.Errors.Select(e => e.ErrorCode).Distinct()
            }
        };
    }
}