using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Domain.Enums;
using EmployeeAttendance.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;
using Microsoft.EntityFrameworkCore;

namespace EmployeeAttendance.Infrastructure.Data;

public static class DbSeeder
{
    public static async Task SeedAsync(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
    {

        if (await context.WorkSites.AnyAsync())
        {
            Console.WriteLine("Work sites already exist. Skipping seed.");
            return;
        }

        Console.WriteLine("========================================");
        Console.WriteLine("SEEDING DATABASE");
        Console.WriteLine("========================================");

        // 1. Find the company created during registration, or create one
        var company = await context.Companies.FirstOrDefaultAsync();

        if (company == null)
        {
            company = new Company
            {
                Id = Guid.NewGuid(),
                CompanyCode = "BSM-001",
                Name = "BSM Headquarters",
                Email = "admin@bsm.com",
                Address = "123 Main Street, Johannesburg",
                SubscriptionPlan = "Starter",
                IsActive = true
            };
            context.Companies.Add(company);
            await context.SaveChangesAsync();
            Console.WriteLine($"Created company: {company.Name} ({company.Id})");
        }
        else
        {
            Console.WriteLine($"Using existing company: {company.Name} ({company.Id})");
        }

        // 2. Create Work Site (Sandton City, Johannesburg)
        var workSite = new WorkSite
        {
            Id = Guid.NewGuid(),
            CompanyId = company.Id,
            Name = "Sandton Office",
            Address = "Sandton City, Johannesburg",
            Latitude = -26.1076m,
            Longitude = 28.0567m,
            QrCodeValue = "BSM-SANDTON-2024",
            RadiusMeters = 100,
            Description = "Main office building, 5th floor",
            IsActive = true
        };
        context.WorkSites.Add(workSite);
        await context.SaveChangesAsync();

        Console.WriteLine($"Created work site: {workSite.Name}");
        Console.WriteLine($"  WorkSiteId: {workSite.Id}");
        Console.WriteLine($"  QR Code: {workSite.QrCodeValue}");
        Console.WriteLine($"  GPS: {workSite.Latitude}, {workSite.Longitude}");

        // 3. Link the most recent registered user to this company
        var user = await userManager.Users
            .OrderByDescending(u => u.CreatedAt)
            .FirstOrDefaultAsync();

        if (user != null)
        {
            Console.WriteLine($"Linking user: {user.Email} ({user.Id})");

            user.CompanyId = company.Id;
            await userManager.UpdateAsync(user);

            var employee = await context.Employees
                .FirstOrDefaultAsync(e => e.UserId == user.Id);

            if (employee != null)
            {
                employee.CompanyId = company.Id;
                await context.SaveChangesAsync();
                Console.WriteLine($"Updated employee: {employee.FullName}");
            }
            else
            {
                // Create employee if missing
                employee = new Employee
                {
                    Id = Guid.NewGuid(),
                    UserId = user.Id,
                    CompanyId = company.Id,
                    FullName = user.Email?.Split('@')[0] ?? "Unknown User",
                    Email = user.Email!,
                    Role = UserRole.Employee,
                    IsActive = true
                };
                context.Employees.Add(employee);
                await context.SaveChangesAsync();
                Console.WriteLine($"Created employee: {employee.FullName}");
            }
        }
        else
        {
            Console.WriteLine("WARNING: No users found to link!");
        }

        Console.WriteLine("========================================");
        Console.WriteLine("SEEDING COMPLETE");
        Console.WriteLine("========================================");
    }
}