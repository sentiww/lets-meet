using FluentValidation;

namespace LetsMeet.WebAPI.Validators;

internal abstract class ApiValidator<T> : AbstractValidator<T>, IApiValidator<T>
{
    public abstract string Title { get; }
}