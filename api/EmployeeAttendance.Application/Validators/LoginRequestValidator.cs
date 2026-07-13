using FluentValidation;
using EmployeeAttendance.Application.DTOs.Auth;

namespace EmployeeAttendance.Application.Validators;

/// <summary>
/// LoginRequestValidator checks if login input is valid.
/// 
/// Rules:
/// - Email must be valid format
/// - Password must not be empty
/// 
/// This runs BEFORE the service is called, preventing wasted database calls.
/// </summary>
public class LoginRequestValidator : AbstractValidator<LoginRequestDto>
{
    public LoginRequestValidator()
    {
        RuleFor(x => x.Email)
            .NotEmpty().WithMessage("Email is required")
            .EmailAddress().WithMessage("Please enter a valid email address");

        RuleFor(x => x.Password)
            .NotEmpty().WithMessage("Password is required")
            .MinimumLength(6).WithMessage("Password must be at least 6 characters");
    }
}