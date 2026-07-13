using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Application.DTOs.Attendance;

/// <summary>
/// SubmitAttendanceDto carries attendance data FROM Flutter TO API.
/// 
/// The Flutter app sends this after scanning QR + capturing GPS.
/// </summary>
public class SubmitAttendanceDto
{
    public Guid WorkSiteId { get; set; }
    public string QrCodeValue { get; set; } = string.Empty;
    public decimal Latitude { get; set; }
    public decimal Longitude { get; set; }
    public string DeviceName { get; set; } = string.Empty;
    public string DeviceModel { get; set; } = string.Empty;
    public string OperatingSystem { get; set; } = string.Empty;
    public string OsVersion { get; set; } = string.Empty;
    public string AppVersion { get; set; } = string.Empty;
    public ScanType ScanType { get; set; }
}