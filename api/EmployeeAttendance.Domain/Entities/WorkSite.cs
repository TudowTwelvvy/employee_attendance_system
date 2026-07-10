namespace EmployeeAttendance.Domain.Entities;

public class WorkSite
{
    public Guid Id { get; set; }
    public Guid CompanyId { get; set; }
    public string Name { get; set; } = string.Empty;
    public string? Address { get; set; }
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public double GeofenceRadiusMeters { get; set; } = 100;
    public string? QrCodeValue { get; set; }
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Company Company { get; set; } = null!;
    public ICollection<AttendanceRecord> AttendanceRecords { get; set; } = new List<AttendanceRecord>();
}
