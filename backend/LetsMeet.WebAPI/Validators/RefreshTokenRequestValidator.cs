using FluentValidation;
using LetsMeet.WebAPI.Contracts.Requests;

namespace LetsMeet.WebAPI.Validators;

internal sealed class RefreshTokenRequestValidator : ApiValidator<RefreshTokenRequest>
{
    public override string Title => nameof(RefreshTokenRequestValidator);

    public RefreshTokenRequestValidator()
    {
        RuleFor(r => r.RefreshToken)
            .NotNull()
            .NotEmpty()
            .WithMessage("Refresh token must be set.")
            .WithErrorCode("REFRESH_TOKEN_NOT_SET");
    }
}