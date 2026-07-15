using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EmployeeAttendance.Application.DTOs.Attendance;
using EmployeeAttendance.Application.Interfaces.Services;

namespace EmployeeAttendance.API.Controllers;

/// <summary>
/// AttendanceController handles QR scanning and attendance history.
/// All endpoints require authentication (JWT token in header).
/// Routes:
/// POST /api/attendance/submit  ...Submit scan
/// GET  /api/attendance/history.. get history
/// GET  /api/attendance/today ... get today's status
/// </summary>
[ApiController]
[Route("api/[controller]")]
[Authorize]  // Meaning all endpoints require JWT token
public class AttendanceController : ControllerBase
{
    private readonly IAttendanceService _attendanceService;

    public AttendanceController(IAttendanceService attendanceService)
    {
        _attendanceService = attendanceService;
    }

    /// <summary>
    /// POST /api/attendance/submit
    /// 
    /// Receives: { workSiteId, qrCodeValue, latitude, longitude, scanType, deviceInfo... }
    /// Header:  Authorization: Bearer <JWT token>
    /// Returns: { id, scanTime, status, message }
    /// </summary>
    [HttpPost("submit")]
    public async Task<IActionResult> SubmitAttendance([FromBody] SubmitAttendanceDto request)
    {
        // Extract user ID from JWT token claims
        //ASP.NET Core populates User with the claims from the token. NameIdentifier is the claim that contains the user ID (we set it as sub in the JWT payload).
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userId))
        {
            return Unauthorized(new { message = "User not authenticated" });
        }

        var response = await _attendanceService.SubmitAttendanceAsync(request, userId);
        return Ok(response);
    }

    /// <summary>
    /// GET /api/attendance/history?startDate=2026-07-01&endDate=2026-07-15
    /// 
    /// Returns: List of attendance records
    /// </summary>
    [HttpGet("history")]
    public async Task<IActionResult> GetHistory(
        [FromQuery] DateTime? startDate,
        [FromQuery] DateTime? endDate)
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userId))
        {
            return Unauthorized();
        }

        var records = await _attendanceService.GetAttendanceHistoryAsync(userId, startDate, endDate);
        return Ok(records);
    }

    /// <summary>
    /// GET /api/attendance/today
    /// 
    /// Returns: Today's check-in status or null
    /// </summary>
    [HttpGet("today")]
    public async Task<IActionResult> GetTodayStatus()
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userId))
        {
            return Unauthorized();
        }

        var status = await _attendanceService.GetTodayAttendanceAsync(userId);

        if (status == null)
        {
            return Ok(new { message = "No attendance recorded today" });
        }

        return Ok(status);
    }
}