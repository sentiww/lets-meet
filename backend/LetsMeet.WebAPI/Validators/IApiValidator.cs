using FluentValidation;

namespace LetsMeet.WebAPI.Validators;

internal interface IApiValidator<in T> : IValidator<T>
{
    public string Title { get; }
}