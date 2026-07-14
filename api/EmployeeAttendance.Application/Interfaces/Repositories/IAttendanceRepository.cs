using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Application.Interfaces.Repositories;

public interface IAttendanceRepository
{
    Task<AttendanceRecord> CreateAsync(AttendanceRecord record);
    Task<AttendanceRecord?> GetByIdAsync(Guid id);
    Task<List<AttendanceRecord>> GetByEmployeeIdAsync(Guid employeeId);
    Task<List<AttendanceRecord>> GetByEmployeeAndDateRangeAsync(
        Guid employeeId,
        DateTime startDate,
        DateTime endDate);
    Task<AttendanceRecord?> GetTodayCheckInAsync(Guid employeeId);
    Task<bool> HasCheckedInTodayAsync(Guid employeeId);
}