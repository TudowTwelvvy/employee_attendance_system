using Microsoft.AspNetCore.Identity;

namespace EmployeeAttendance.Infrastructure.Identity;

public class ApplicationUser : IdentityUser
{
    //which company this user belongs to
    public Guid? CompanyId { get; set; }

    // When the user was created
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;

    // Soft delete flag
    public bool IsActive { get; set; } = true;
}