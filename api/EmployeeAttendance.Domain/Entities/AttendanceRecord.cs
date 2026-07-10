using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Domain.Entities;

public class AttendanceRecord
{
    public Guid Id { get; set; }
    public Guid EmployeeId { get; set; }
    public Guid WorkSiteId { get; set; }
    public string QrCodeValue { get; set; } = string.Empty;
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public decimal? DistanceFromSite { get; set; }
    public string DeviceName { get; set; } = string.Empty;
    public string DeviceModel { get; set; } = string.Empty;
    public string OperatingSystem { get; set; } = string.Empty;
    public string OsVersion { get; set; } = string.Empty;
    public string AppVersion { get; set; } = string.Empty;
    public DateTime ScanTime { get; set; }
    public DateTime ScanDate { get; set; }
    public ScanType ScanType { get; set; }
    public AttendanceStatus Status { get; set; } = AttendanceStatus.Valid;
    public bool IsWithinGeofence { get; set; }
    public string? Notes { get; set; }
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public Employee Employee { get; set; } = null!;
    public WorkSite WorkSite { get; set; } = null!;
}
