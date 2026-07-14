using Microsoft.EntityFrameworkCore;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Application.Interfaces.Repositories;
using EmployeeAttendance.Infrastructure.Data;

namespace EmployeeAttendance.Infrastructure.Repositories;

/// <summary>
/// AttendanceRepository handles all database operations for attendance records.
/// 
/// Key responsibilities:
/// - Create attendance records (when user scans QR + GPS)
/// - Retrieve attendance history (for employee dashboard)
/// - Check if employee already checked in today (prevent double check-in)
/// 
/// This is the ONLY place that knows the AttendanceRecords table structure.
/// </summary>
public class AttendanceRepository : IAttendanceRepository
{
    // Same dependency pattern as EmployeeRepository
    private readonly ApplicationDbContext _dbContext;

    public AttendanceRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    // ============================================
    // METHOD: CreateAsync
    // ============================================
    // Purpose: Save a new attendance record (check-in or check-out)
    // When called: After QR scan + GPS validation passes
    public async Task<AttendanceRecord> CreateAsync(AttendanceRecord record)
    {
        _dbContext.AttendanceRecords.Add(record);
        await _dbContext.SaveChangesAsync();
        return record;
    }

    // ============================================
    // METHOD: GetByIdAsync
    // ============================================
    // Purpose: Get a single attendance record by ID
    // Used when: Admin wants to view details of a specific record
    public async Task<AttendanceRecord?> GetByIdAsync(Guid id)
    {
        // Include = Eager loading — fetch related Employee and WorkSite data in ONE query
        // Without Include: You'd get "null" for Employee/WorkSite properties
        // SQL: INNER JOIN Employees, INNER JOIN WorkSites
        return await _dbContext.AttendanceRecords
            .Include(a => a.Employee)
            .Include(a => a.WorkSite)
            .FirstOrDefaultAsync(a => a.Id == id);
    }

    // ============================================
    // METHOD: GetByEmployeeIdAsync
    // ============================================
    // Purpose: Get ALL attendance records for a specific employee
    // Used when: Employee views their full attendance history
    // Sorted by: Most recent first (ScanTime descending)
    public async Task<List<AttendanceRecord>> GetByEmployeeIdAsync(Guid employeeId)
    {
        return await _dbContext.AttendanceRecords
            .Where(a => a.EmployeeId == employeeId)
            .Include(a => a.WorkSite)  // Include site name for display
            .OrderByDescending(a => a.ScanTime)  // Newest first
            .ToListAsync();
    }

    // ============================================
    // METHOD: GetByEmployeeAndDateRangeAsync
    // ============================================
    // Purpose: Get attendance records within a date range (for reports/filters)
    // Used when: Manager views "This week's attendance" or "Last month's records"
    // Parameters:
    //   employeeId = which employee
    //   startDate = from date (inclusive)
    //   endDate = to date (inclusive)
    public async Task<List<AttendanceRecord>> GetByEmployeeAndDateRangeAsync(
        Guid employeeId,
        DateTime startDate,
        DateTime endDate)
    {
        return await _dbContext.AttendanceRecords
            .Where(a => a.EmployeeId == employeeId)
            .Where(a => a.ScanDate >= startDate && a.ScanDate <= endDate)
            .Include(a => a.WorkSite)
            .OrderByDescending(a => a.ScanTime)
            .ToListAsync();
    }

    // ============================================
    // METHOD: GetTodayCheckInAsync
    // ============================================
    // Purpose: Find today's check-in record for an employee
    // Used when: App needs to show "You checked in at 9:00 AM today"
    // Logic: ScanDate = today's date, ScanType = CheckIn
    public async Task<AttendanceRecord?> GetTodayCheckInAsync(Guid employeeId)
    {
        var today = DateTime.UtcNow.Date;  // Midnight UTC today

        return await _dbContext.AttendanceRecords
            .Where(a => a.EmployeeId == employeeId)
            .Where(a => a.ScanDate == today)
            .Where(a => a.ScanType == Domain.Enums.ScanType.CheckIn)
            .Include(a => a.WorkSite)
            .FirstOrDefaultAsync();
    }

    // ============================================
    // METHOD: HasCheckedInTodayAsync
    // ============================================
    // Purpose: Quick check if employee already checked in today
    // Used when: Preventing double check-in (show "Check Out" button instead)
    // Returns: bool (true = already checked in, false = not yet)
    public async Task<bool> HasCheckedInTodayAsync(Guid employeeId)
    {
        var today = DateTime.UtcNow.Date;

        // AnyAsync = most efficient for yes/no checks
        // Stops at first match instead of counting all records
        return await _dbContext.AttendanceRecords
            .AnyAsync(a => a.EmployeeId == employeeId
                        && a.ScanDate == today
                        && a.ScanType == Domain.Enums.ScanType.CheckIn);
    }
}
