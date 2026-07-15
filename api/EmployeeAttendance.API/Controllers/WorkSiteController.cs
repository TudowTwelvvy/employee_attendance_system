using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using EmployeeAttendance.Application.Interfaces.Repositories;
using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.API.Controllers;

[ApiController]
[Route("api/[controller]")]
[Authorize]
public class WorkSiteController : ControllerBase
{
    private readonly IWorkSiteRepository _workSiteRepository;

    public WorkSiteController(IWorkSiteRepository workSiteRepository)
    {
        _workSiteRepository = workSiteRepository;
    }

    /// <summary>
    /// GET /api/worksite
    /// 
    /// Returns all work sites for the user's company
    /// </summary>
    [HttpGet]
    public async Task<IActionResult> GetAll()
    {
        //Filter by CompanyId from JWT claims (multi-tenant)
        // For now, return all (will be fixed in Lesson 8 with middleware)
        var sites = await _workSiteRepository.GetByCompanyIdAsync(Guid.Empty);
        return Ok(sites);
    }

    /// <summary>
    /// GET /api/worksite/{id}
    /// 
    /// Returns a specific work site
    /// </summary>
    [HttpGet("{id}")]
    public async Task<IActionResult> GetById(Guid id)
    {
        var site = await _workSiteRepository.GetByIdAsync(id);

        if (site == null)
        {
            return NotFound(new { message = "Work site not found" });
        }

        return Ok(site);
    }

    [HttpPost("worksite")]
    public async Task<IActionResult> Create([FromBody] WorkSite workSite)
    {
        var createdWorkSite = await _workSiteRepository.CreateAsync(workSite);
        return Ok(createdWorkSite);
    }


}