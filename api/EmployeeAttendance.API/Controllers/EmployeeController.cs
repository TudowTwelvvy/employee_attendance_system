using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EmployeeAttendance.Application.Interfaces.Repositories;

namespace EmployeeAttendance.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class EmployeeController : ControllerBase
{
    private readonly IEmployeeRepository _employeeRepository;

    public EmployeeController(IEmployeeRepository employeeRepository)
    {
        _employeeRepository = employeeRepository;
    }

    /// <summary>
    /// GET /api/employee/profile
    /// 
    /// Returns current employee's profile
    /// </summary>
    [HttpGet("profile")]
    public async Task<IActionResult> GetProfile()
    {
        var userId = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;

        if (string.IsNullOrEmpty(userId))
        {
            return Unauthorized();
        }

        var employee = await _employeeRepository.GetByUserIdAsync(userId);

        if (employee == null)
        {
            return NotFound(new { message = "Employee not found" });
        }

        return Ok(new
        {
            employee.Id,
            employee.FullName,
            employee.Email,
            employee.EmployeeCode,
            employee.Department,
            employee.Designation,
            employee.Role,
            employee.IsActive
        });
    }
}