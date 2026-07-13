namespace EmployeeAttendance.Application.DTOs.Attendance;

public class AttendanceResponseDto
{
    public Guid Id { get; set; }
    public DateTime ScanTime { get; set; }
    public string ScanType { get; set; } = string.Empty;
    public string Status { get; set; } = string.Empty;
    public string? SiteName { get; set; }
    public bool IsWithinGeofence { get; set; }
    public string? Message { get; set; }
}