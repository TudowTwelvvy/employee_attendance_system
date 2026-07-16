using Microsoft.AspNetCore.Mvc;
using EmployeeAttendance.Infrastructure.Data;
using EmployeeAttendance.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;

namespace EmployeeAttendance.API.Controllers;

[ApiController]
[Route("api/[controller]")]
public class SeedController : ControllerBase
{
    private readonly ApplicationDbContext _context;
    private readonly UserManager<ApplicationUser> _userManager;

    public SeedController(ApplicationDbContext context, UserManager<ApplicationUser> userManager)
    {
        _context = context;
        _userManager = userManager;
    }

    [HttpPost]
    public async Task<IActionResult> Seed()
    {
        await DbSeeder.SeedAsync(_context, _userManager);
        return Ok(new { message = "Database seeded successfully" });
    }
}