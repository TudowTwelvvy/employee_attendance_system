using EmployeeAttendance.Application.DTOs.Attendance;

namespace EmployeeAttendance.Application.Interfaces.Services;

public interface IAttendanceService
{
    /// <summary>
    /// Submit attendance record (QR scan + GPS validation)
    /// </summary>
    Task<AttendanceResponseDto> SubmitAttendanceAsync(
        SubmitAttendanceDto request,
        string userId);

    /// <summary>
    /// Get attendance history for current user
    /// </summary>
    Task<List<AttendanceResponseDto>> GetAttendanceHistoryAsync(
        string userId,
        DateTime? startDate = null,
        DateTime? endDate = null);

    /// <summary>
    /// Get today's attendance status
    /// </summary>
    Task<AttendanceResponseDto?> GetTodayAttendanceAsync(string userId);
}