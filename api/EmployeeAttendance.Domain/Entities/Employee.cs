using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Domain.Entities;

public class Employee
{
    public Guid Id { get; set; }
    public string UserId { get; set; } = string.Empty; // Links to AspNetUsers
    public Guid CompanyId { get; set; }
    public string FullName { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? Phone { get; set; }
    public string EmployeeCode { get; set; } = string.Empty;
    public string? Department { get; set; }
    public string? Designation { get; set; }
    public DateTime? JoinDate { get; set; }
    public string? ProfilePictureUrl { get; set; }
    public UserRole Role { get; set; } = UserRole.Employee;
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Company Company { get; set; } = null!;
    public ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();
}