namespace EmployeeAttendance.Application.Interfaces.Services;

public interface IIdentityService
{
    Task<AuthResult> CreateUserAsync(string email, string password, string? phoneNumber = null);
    Task<AuthResult> CheckPasswordAsync(string email, string password);
    Task<IList<string>> GetRolesAsync(string userId);
    Task<AuthResult> AddToRoleAsync(string userId, string role);
    Task<string?> GetUserIdByEmailAsync(string email);
    Task<bool> UserExistsAsync(string email);
    Task<IdentityUserInfo?> GetUserByEmailAsync(string email);
}

public class IdentityUserInfo
{
    public string Id { get; set; } = string.Empty;
    public string Email { get; set; } = string.Empty;
    public string? UserName { get; set; }
    public Guid? CompanyId { get; set; }
    public bool IsActive { get; set; }
}

public class AuthResult
{
    public bool Succeeded { get; set; }
    public List<string> Errors { get; set; } = new();

    public static AuthResult Success() => new() { Succeeded = true };
    public static AuthResult Failed(params string[] errors) => new()
    {
        Succeeded = false,
        Errors = errors.ToList()
    };
}