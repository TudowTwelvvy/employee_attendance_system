namespace EmployeeAttendance.Application.DTOs.Auth;

/// LoginRequestDto carries login credentials FROM the Flutter app TO the API.
public class LoginRequestDto
{
    public string Email { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}