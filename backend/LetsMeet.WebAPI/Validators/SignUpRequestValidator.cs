using FluentValidation;
using LetsMeet.Persistence;
using LetsMeet.WebAPI.Contracts.Requests;
using Microsoft.EntityFrameworkCore;

namespace LetsMeet.WebAPI.Validators;

internal sealed class SignUpRequestValidator : ApiValidator<SignUpRequest>
{
    public override string Title => nameof(SignUpRequestValidator);
    
    private readonly LetsMeetDbContext _context;

    public SignUpRequestValidator(LetsMeetDbContext context)
    {
        _context = context;

        RuleFor(r => r.Username)
            .NotNull()
            .NotEmpty()
            .WithMessage("Username must be set.")
            .WithErrorCode("USERNAME_NOT_SET")
            .MustAsync(BeUniqueUsernameAsync)
            .WithMessage("Username taken.")
            .WithErrorCode("USERNAME_TAKEN");
        
        RuleFor(r => r.Password)
            .NotNull()
            .NotEmpty()
            .WithMessage("Password must be set.")
            .WithErrorCode("PASSWORD_NOT_SET")
            .Must(ContainLowerCaseCharacter)
            .WithMessage("Password must contain lower case character.")
            .WithErrorCode("PASSWORD_RULE_NOT_SATISFIED_LOWER_CASE")
            .Must(ContainUpperCaseCharacter)
            .WithMessage("Password must contain upper case character")
            .WithErrorCode("PASSWORD_RULE_NOT_SATISFIED_UPPER_CASE")
            .Must(ContainNumber)
            .WithMessage("Password must contain number.")
            .WithErrorCode("PASSWORD_RULE_NOT_SATISFIED_NUMBER");

        RuleFor(r => r.Email)
            .NotNull()
            .NotEmpty()
            .WithMessage("Email must be set.")
            .WithErrorCode("EMAIL_NOT_SET")
            .MustAsync(BeUniqueEmailAsync)
            .WithMessage("Email taken.")
            .WithErrorCode("EMAIL_TAKEN");

        RuleFor(r => r.Name)
            .NotNull()
            .NotEmpty()
            .WithMessage("Name must be set.")
            .WithErrorCode("NAME_NOT_SET");
        
        RuleFor(r => r.Surname)
            .NotNull()
            .NotEmpty()
            .WithMessage("Surname must be set.")
            .WithErrorCode("SURNAME_NOT_SET");

        RuleFor(r => r.DateOfBirth)
            .Must(BeOver18)
            .WithMessage("Must be over 18.")
            .WithErrorCode("NOT_OVER_18");
    }

    private static bool BeOver18(DateTimeOffset dateOfBirth) => dateOfBirth.AddYears(18) <= DateTime.UtcNow;

    private async Task<bool> BeUniqueEmailAsync(
        string email, 
        CancellationToken cancellationToken = default)
    {
        var emailTaken = await _context.Users.AnyAsync(u => u.Email == email, cancellationToken);

        return emailTaken is false;
    }

    private static bool ContainNumber(string password) => password.Any(char.IsNumber);

    private static bool ContainUpperCaseCharacter(string password) => password.Any(char.IsUpper); 

    private static bool ContainLowerCaseCharacter(string password) => password.Any(char.IsLower); 

    private async Task<bool> BeUniqueUsernameAsync(
        string username, 
        CancellationToken cancellationToken = default)
    {
        var usernameTaken = await _context.Users.AnyAsync(u => u.Username == username, cancellationToken);

        return usernameTaken is false;
    }
}