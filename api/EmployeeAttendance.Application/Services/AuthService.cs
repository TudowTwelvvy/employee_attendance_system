using EmployeeAttendance.Application.DTOs.Auth;
using EmployeeAttendance.Application.Interfaces.Repositories;
using EmployeeAttendance.Application.Interfaces.Services;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Application.Services;

/// <summary>
/// AuthService implements authentication business logic.
/// 
/// It depends ONLY on interfaces from the Application Layer:
/// - IIdentityService (user management)
/// - IJwtTokenService (token generation)
/// - IEmployeeRepository (employee data)
/// 
/// It knows NOTHING about:
/// - ASP.NET Core Identity
/// - JWT libraries
/// - Entity Framework
/// </summary>
public class AuthService : IAuthService
{
    private readonly IIdentityService _identityService;
    private readonly IJwtTokenService _jwtTokenService;
    private readonly IEmployeeRepository _employeeRepository;
    private readonly ICompanyRepository _companyRepository;
    public AuthService(
        IIdentityService identityService,
        IJwtTokenService jwtTokenService,
        IEmployeeRepository employeeRepository,
        ICompanyRepository companyRepository)
    {
        _identityService = identityService;
        _jwtTokenService = jwtTokenService;
        _employeeRepository = employeeRepository;
        _companyRepository = companyRepository;
    }

    public async Task<LoginResponseDto> LoginAsync(LoginRequestDto request)
    {
        // Check credentials through abstraction
        var result = await _identityService.CheckPasswordAsync(request.Email, request.Password);
        if (!result.Succeeded)
        {
            throw new UnauthorizedAccessException("Invalid email or password");
        }

        // Get user info
        var user = await _identityService.GetUserByEmailAsync(request.Email);
        if (user == null)
        {
            throw new UnauthorizedAccessException("Invalid email or password");
        }

        // Get roles
        var roles = await _identityService.GetRolesAsync(user.Id);

        // Generate tokens through abstraction
        var token = _jwtTokenService.GenerateToken(
            user.Id,
            user.Email,
            user.UserName ?? "",
            user.CompanyId,
            roles);

        var refreshToken = _jwtTokenService.GenerateRefreshToken();

        // Get employee info
        var employee = await _employeeRepository.GetByUserIdAsync(user.Id);

        return new LoginResponseDto
        {
            Success = true,
            Message = "Login successful",
            Token = token,
            RefreshToken = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddHours(1),
            User = new UserDto
            {
                Id = user.Id,
                FullName = employee?.FullName ?? user.UserName ?? "",
                Email = user.Email,
                Role = roles.FirstOrDefault() ?? "Employee",
                CompanyName = null
            }
        };
    }

    public async Task<LoginResponseDto> RegisterAsync(RegisterRequestDto request)
    {
        // Check if email exists
        if (await _identityService.UserExistsAsync(request.Email))
        {
            throw new InvalidOperationException("Email already registered");
        }

        // Create user through abstraction
        var result = await _identityService.CreateUserAsync(request.Email, request.Password);
        if (!result.Succeeded)
        {
            throw new InvalidOperationException($"Registration failed: {string.Join(", ", result.Errors)}");
        }

        // Get the newly created user
        var user = await _identityService.GetUserByEmailAsync(request.Email);
        if (user == null)
        {
            throw new InvalidOperationException("User creation failed");
        }

        // Assign default role
        await _identityService.AddToRoleAsync(user.Id, UserRole.Employee.ToString());

        // CREATE COMPANY
        Guid companyId;
        if (!string.IsNullOrWhiteSpace(request.CompanyName))
        {
            var company = new Company
            {
                Id = Guid.NewGuid(),
                CompanyCode = GenerateCompanyCode(request.CompanyName), // NEW
                Name = request.CompanyName,
                Email = request.Email,
                IsActive = true
            };

            await _companyRepository.CreateAsync(company);
            companyId = company.Id;
        }
        else
        {
            throw new InvalidOperationException("Company name is required for registration");
        }

        Console.WriteLine($"Creating employee with UserId: {user.Id}, CompanyId: {companyId}");

        // Create Employee record
        var employee = new Employee
        {
            Id = Guid.NewGuid(),
            UserId = user.Id,
            CompanyId = companyId,
            FullName = request.FullName,
            Email = request.Email,
            Role = UserRole.Employee,
        };

        await _employeeRepository.CreateAsync(employee);

        // Generate tokens
        var roles = await _identityService.GetRolesAsync(user.Id);
        var token = _jwtTokenService.GenerateToken(
            user.Id,
            user.Email,
            user.UserName ?? "",
            user.CompanyId,
            roles);

        var refreshToken = _jwtTokenService.GenerateRefreshToken();

        return new LoginResponseDto
        {
            Success = true,
            Message = "Registration successful",
            Token = token,
            RefreshToken = refreshToken,
            ExpiresAt = DateTime.UtcNow.AddHours(1),
            User = new UserDto
            {
                Id = user.Id,
                FullName = employee.FullName,
                Email = user.Email,
                Role = UserRole.Employee.ToString()
            }
        };
    }

    public Task<LoginResponseDto> RefreshTokenAsync(string refreshToken)
    {
        throw new NotImplementedException();
    }

    public Task LogoutAsync(string userId)
    {
        return Task.CompletedTask;
    }




    private static string GenerateCompanyCode(string companyName)
    {
        var prefix = new string(companyName
            .Split(' ')
            .Select(w => char.ToUpper(w[0]))
            .Take(3)
            .ToArray());

        if (prefix.Length < 2) prefix = companyName[..Math.Min(3, companyName.Length)].ToUpper();

        var random = new Random();
        var suffix = random.Next(1000, 9999).ToString();

        return $"{prefix}-{suffix}";
    }
}