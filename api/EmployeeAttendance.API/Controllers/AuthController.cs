using Microsoft.AspNetCore.Mvc;
using EmployeeAttendance.Application.DTOs.Auth;
using EmployeeAttendance.Application.Interfaces.Services;

namespace EmployeeAttendance.API.Controllers;

/// <summary>
/// This controller is THIN. It only:
/// - Receives HTTP requests
/// - Calls Application services
/// - Returns HTTP responses
/// 
/// All business logic lives in AuthService (Application Layer).
/// </summary>
[ApiController]
[Route("api/[controller]")] //api/auth
public class AuthController : ControllerBase
{
    private readonly IAuthService _authService;

    public AuthController(IAuthService authService)
    {
        _authService = authService;
    }

    /// <summary>
    /// POST /api/auth/login
    /// Receives: { email, password }
    /// Returns: { success, token, user }
    /// </summary>
    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequestDto request)
    {
        var response = await _authService.LoginAsync(request);
        return Ok(response);
    }

    /// <summary>
    /// POST /api/auth/register
    /// Receives: { fullName, email, password, confirmPassword, companyCode?, companyName? }
    /// Returns: { success, token, user }
    /// </summary>
    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequestDto request)
    {
        var response = await _authService.RegisterAsync(request);
        return Ok(response);
    }

    /// <summary>
    /// POST /api/auth/refresh
    /// Receives: { refreshToken }
    /// Returns: { success, token, user }
    /// </summary>
    [HttpPost("refresh")]
    public async Task<IActionResult> RefreshToken([FromBody] string refreshToken)
    {
        var response = await _authService.RefreshTokenAsync(refreshToken);
        return Ok(response);
    }

    [HttpPost("logout")]
    public async Task<IActionResult> Logout([FromRoute] string userId)
    {
        var userIdFromToken = User.FindFirst(System.Security.Claims.ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdFromToken) || userIdFromToken != userId)
        {
            return Unauthorized();
        }

        await _authService.LogoutAsync(userId);
        return Ok(new { message = "Logged out successfully" });
    }
}