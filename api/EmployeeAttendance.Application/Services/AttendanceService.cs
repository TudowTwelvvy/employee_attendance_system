using EmployeeAttendance.Application.DTOs.Attendance;
using EmployeeAttendance.Application.Interfaces.Repositories;
using EmployeeAttendance.Application.Interfaces.Services;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Application.Services;

/// <summary>
/// AttendanceService implements the core business logic for QR scanning.
/// 
/// Responsibilities:
/// - Validate QR code against work site
/// - Check geofence (GPS distance from work site)
/// - Enforce check-in/check-out rules
/// - Determine attendance status (Valid, InvalidQr, InvalidLocation)
/// </summary>
public class AttendanceService : IAttendanceService
{
    private readonly IAttendanceRepository _attendanceRepository;
    private readonly IEmployeeRepository _employeeRepository;
    private readonly IWorkSiteRepository _workSiteRepository;

    public AttendanceService(
        IAttendanceRepository attendanceRepository,
        IEmployeeRepository employeeRepository,
        IWorkSiteRepository workSiteRepository)
    {
        _attendanceRepository = attendanceRepository;
        _employeeRepository = employeeRepository;
        _workSiteRepository = workSiteRepository;
    }

    public async Task<AttendanceResponseDto> SubmitAttendanceAsync(
        SubmitAttendanceDto request,
        string userId)
    {
        // Find the employee by Identity user ID
        var employee = await _employeeRepository.GetByUserIdAsync(userId);
        if (employee == null)
        {
            throw new UnauthorizedAccessException("Employee not found");
        }

        // Find the work site
        var workSite = await _workSiteRepository.GetByIdAsync(request.WorkSiteId);
        if (workSite == null)
        {
            throw new InvalidOperationException("Work site not found");
        }

        // Validate QR code
        // The scanned QR must match the work site's expected QR code
        bool isValidQr = workSite.QrCodeValue == request.QrCodeValue;

        // Calculate distance from work site (geofence check)
        double distanceMeters = CalculateDistance(
            (double)request.Latitude,
            (double)request.Longitude,
            (double)workSite.Latitude,
            (double)workSite.Longitude);

        bool isWithinGeofence = distanceMeters <= workSite.RadiusMeters;

        // Enforce check-in/check-out business rules
        if (request.ScanType == ScanType.CheckOut)
        {
            // Can't check out without checking in first
            bool hasCheckedIn = await _attendanceRepository.HasCheckedInTodayAsync(employee.Id);
            if (!hasCheckedIn)
            {
                throw new InvalidOperationException("You must check in before checking out");
            }
        }

        // Determine attendance status
        AttendanceStatus status;
        if (!isValidQr)
        {
            status = AttendanceStatus.InvalidQr;
        }
        else if (!isWithinGeofence)
        {
            status = AttendanceStatus.InvalidLocation;
        }
        else
        {
            status = AttendanceStatus.Valid;
        }

        // Create attendance record
        var record = new AttendanceRecord
        {
            Id = Guid.NewGuid(),
            EmployeeId = employee.Id,
            WorkSiteId = workSite.Id,
            QrCodeValue = request.QrCodeValue,
            Latitude = request.Latitude,
            Longitude = request.Longitude,
            DistanceFromSite = (decimal)distanceMeters,
            DeviceName = request.DeviceName,
            DeviceModel = request.DeviceModel,
            OperatingSystem = request.OperatingSystem,
            OsVersion = request.OsVersion,
            AppVersion = request.AppVersion,
            ScanTime = DateTime.UtcNow,
            ScanDate = DateTime.UtcNow.Date,
            ScanType = request.ScanType,
            Status = status,
            IsWithinGeofence = isWithinGeofence,
            Notes = $"QR Valid: {isValidQr}, Distance: {distanceMeters:F1}m, Geofence: {isWithinGeofence}"
        };

        // Save to database
        await _attendanceRepository.CreateAsync(record);

        // Build response message
        string message = status switch
        {
            AttendanceStatus.Valid => $"{request.ScanType} recorded successfully at {record.ScanTime:HH:mm}",
            AttendanceStatus.InvalidQr => "Invalid QR code. Please scan the correct code for this site.",
            AttendanceStatus.InvalidLocation => $"You are {distanceMeters:F0}m away from site (max {workSite.RadiusMeters}m). Please move closer.",
            AttendanceStatus.Late => "Late check-in recorded.",
            _ => "Unknown status"
        };

        // Return response DTO
        return new AttendanceResponseDto
        {
            Id = record.Id,
            ScanTime = record.ScanTime,
            ScanType = record.ScanType.ToString(),
            Status = record.Status.ToString(),
            SiteName = workSite.Name,
            IsWithinGeofence = record.IsWithinGeofence,
            Message = message
        };
    }

    public async Task<List<AttendanceResponseDto>> GetAttendanceHistoryAsync(
        string userId,
        DateTime? startDate = null,
        DateTime? endDate = null)
    {
        // Find employee
        var employee = await _employeeRepository.GetByUserIdAsync(userId);
        if (employee == null)
        {
            throw new UnauthorizedAccessException("Employee not found");
        }

        // Default to last 30 days if no dates provided
        var start = startDate ?? DateTime.UtcNow.AddDays(-30);
        var end = endDate ?? DateTime.UtcNow;

        // Fetch records
        var records = await _attendanceRepository.GetByEmployeeAndDateRangeAsync(
            employee.Id, start, end);

        // Map to DTOs
        return records.Select(r => new AttendanceResponseDto
        {
            Id = r.Id,
            ScanTime = r.ScanTime,
            ScanType = r.ScanType.ToString(),
            Status = r.Status.ToString(),
            SiteName = null, // Could fetch from WorkSite repo if needed
            IsWithinGeofence = r.IsWithinGeofence,
            Message = r.Status == AttendanceStatus.Valid
                ? $"{r.ScanType} at {r.ScanTime:HH:mm}"
                : r.Status.ToString()
        }).ToList();
    }

    public async Task<AttendanceResponseDto?> GetTodayAttendanceAsync(string userId)
    {
        var employee = await _employeeRepository.GetByUserIdAsync(userId);
        if (employee == null) return null;

        // Get today's check-in
        var todayCheckIn = await _attendanceRepository.GetTodayCheckInAsync(employee.Id);
        if (todayCheckIn == null) return null;

        return new AttendanceResponseDto
        {
            Id = todayCheckIn.Id,
            ScanTime = todayCheckIn.ScanTime,
            ScanType = todayCheckIn.ScanType.ToString(),
            Status = todayCheckIn.Status.ToString(),
            IsWithinGeofence = todayCheckIn.IsWithinGeofence,
            Message = $"Checked in at {todayCheckIn.ScanTime:HH:mm}"
        };
    }

    /// <summary>
    /// Calculate the great-circle distance between two GPS coordinates using the Haversine formula.
    /// 
    /// This is accurate for short distances (like our geofence checks).
    /// </summary>
    private double CalculateDistance(double lat1, double lon1, double lat2, double lon2)
    {
        const double EarthRadiusMeters = 6371000; // Earth's radius in meters

        // Convert degrees to radians
        double dLat = ToRadians(lat2 - lat1);
        double dLon = ToRadians(lon2 - lon1);

        // Haversine formula
        double a = Math.Sin(dLat / 2) * Math.Sin(dLat / 2) +
                   Math.Cos(ToRadians(lat1)) * Math.Cos(ToRadians(lat2)) *
                   Math.Sin(dLon / 2) * Math.Sin(dLon / 2);

        double c = 2 * Math.Atan2(Math.Sqrt(a), Math.Sqrt(1 - a));

        return EarthRadiusMeters * c;
    }

    private double ToRadians(double degrees)
    {
        return degrees * Math.PI / 180;
    }
}