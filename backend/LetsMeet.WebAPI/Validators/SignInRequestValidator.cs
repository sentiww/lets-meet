using FluentValidation;
using LetsMeet.WebAPI.Contracts.Requests;

namespace LetsMeet.WebAPI.Validators;

internal sealed class SignInRequestValidator : ApiValidator<SignInRequest>
{
    public override string Title => nameof(SignInRequestValidator);

    public SignInRequestValidator()
    {
        RuleFor(r => r.Username)
            .NotNull()
            .NotEmpty()
            .WithMessage("Username must be set.")
            .WithErrorCode("USERNAME_NOT_SET");

        RuleFor(r => r.Password)
            .NotNull()
            .NotEmpty()
            .WithMessage("Password must be set.")
            .WithErrorCode("PASSWORD_NOT_SET");
    }
}