using EmployeeAttendance.Application.DTOs.Attendance;
using FluentValidation;

namespace EmployeeAttendance.Application.Validators
{
    public class SubmitAttendanceValidator : AbstractValidator<SubmitAttendanceDto>
    {
        public SubmitAttendanceValidator()
        {
            RuleFor(x => x.WorkSiteId)
                .NotEmpty();

            RuleFor(x => x.QrCodeValue)
                .NotEmpty();

            RuleFor(x => x.Latitude)
                .InclusiveBetween(-90m, 90m)
                .WithMessage("Latitude must be between -90 and 90.");

            RuleFor(x => x.Longitude)
                .InclusiveBetween(-180m, 180m)
                .WithMessage("Longitude must be between -180 and 180.");
        }
    }
}