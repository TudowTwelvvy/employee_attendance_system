using Microsoft.AspNetCore.Identity;
using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Infrastructure.Data;

public static class RoleSeeder
{
    public static async Task SeedRolesAsync(RoleManager<IdentityRole> roleManager)
    {
        var roles = Enum.GetNames(typeof(UserRole));
        foreach (var roleName in roles)
        {
            if (!await roleManager.RoleExistsAsync(roleName))
            {
                await roleManager.CreateAsync(new IdentityRole(roleName));
                Console.WriteLine($"Created role: {roleName}");
            }
        }
    }
}