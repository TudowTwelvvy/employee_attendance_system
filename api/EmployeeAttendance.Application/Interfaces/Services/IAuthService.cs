using EmployeeAttendance.Application.DTOs.Auth;

namespace EmployeeAttendance.Application.Interfaces.Services;


/// <summary>
/// IAuthService defines WHAT authentication operations exist.
/// 
/// The Application Layer says: "I need a service that can login and register."
/// The Infrastructure Layer says: "I'll implement that using Identity + JWT."
/// 
/// This follows Dependency Inversion: high-level modules depend on abstractions,
/// not concrete implementations.
/// </summary>

public interface IAuthService
{
    /// <summary>
    /// Authenticate user and return JWT token
    /// </summary>
    Task<LoginResponseDto> LoginAsync(LoginRequestDto request);

    /// <summary>
    /// Register new user and create/join company
    /// </summary>
    Task<LoginResponseDto> RegisterAsync(RegisterRequestDto request);

    /// <summary>
    /// Generate new access token from refresh token
    /// </summary>
    Task<LoginResponseDto> RefreshTokenAsync(string refreshToken);

    /// <summary>
    /// Logout user and revoke tokens
    /// </summary>
    Task LogoutAsync(string userId);
}