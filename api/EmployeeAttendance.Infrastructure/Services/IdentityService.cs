using Microsoft.AspNetCore.Identity;
using EmployeeAttendance.Application.Interfaces.Services;
using EmployeeAttendance.Infrastructure.Identity;

namespace EmployeeAttendance.Infrastructure.Services;

public class IdentityService : IIdentityService
{
    private readonly UserManager<ApplicationUser> _userManager;
    private readonly SignInManager<ApplicationUser> _signInManager;

    public IdentityService(
        UserManager<ApplicationUser> userManager,
        SignInManager<ApplicationUser> signInManager)
    {
        _userManager = userManager;
        _signInManager = signInManager;
    }

    // CHANGED: IdentityResult → AuthResult
    public async Task<AuthResult> CreateUserAsync(string email, string password, string? phoneNumber = null)
    {
        var user = new ApplicationUser
        {
            UserName = email,
            Email = email,
            PhoneNumber = phoneNumber,
            EmailConfirmed = true
        };

        var result = await _userManager.CreateAsync(user, password);

        if (result.Succeeded)
            return AuthResult.Success();

        return AuthResult.Failed(result.Errors.Select(e => e.Description).ToArray());
    }

    // CHANGED: IdentityResult → AuthResult
    public async Task<AuthResult> CheckPasswordAsync(string email, string password)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user == null)
            return AuthResult.Failed("Invalid email or password");

        var result = await _signInManager.CheckPasswordSignInAsync(user, password, lockoutOnFailure: true);

        if (result.Succeeded)
            return AuthResult.Success();

        return AuthResult.Failed("Invalid email or password");
    }

    public async Task<IList<string>> GetRolesAsync(string userId)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null) return new List<string>();

        return await _userManager.GetRolesAsync(user);
    }

    // CHANGED: IdentityResult → AuthResult
    public async Task<AuthResult> AddToRoleAsync(string userId, string role)
    {
        var user = await _userManager.FindByIdAsync(userId);
        if (user == null)
            return AuthResult.Failed("User not found");

        var result = await _userManager.AddToRoleAsync(user, role);

        if (result.Succeeded)
            return AuthResult.Success();

        return AuthResult.Failed(result.Errors.Select(e => e.Description).ToArray());
    }

    public async Task<string?> GetUserIdByEmailAsync(string email)
    {
        var user = await _userManager.FindByEmailAsync(email);
        return user?.Id;
    }

    public async Task<bool> UserExistsAsync(string email)
    {
        return await _userManager.FindByEmailAsync(email) != null;
    }

    public async Task<IdentityUserInfo?> GetUserByEmailAsync(string email)
    {
        var user = await _userManager.FindByEmailAsync(email);
        if (user == null) return null;

        return new IdentityUserInfo
        {
            Id = user.Id,
            Email = user.Email!,
            UserName = user.UserName,
            CompanyId = user.CompanyId,
            IsActive = user.IsActive
        };
    }
}