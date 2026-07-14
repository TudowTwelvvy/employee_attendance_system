namespace EmployeeAttendance.Domain.Entities;

/// <summary>
/// Company represents a tenant in this system. So, each company has its own employees, sites, and attendance records.
/// </summary>
public class Company
{
    public Guid Id { get; set; }
    public String CompanyCode { get; set; } = string.Empty; public string Name { get; set; } = string.Empty;
    public string? Address { get; set; }
    public string? Phone { get; set; }
    public string Email { get; set; } = string.Empty;
    public string? LogoUrl { get; set; }
    public string SubscriptionPlan { get; set; } = "Free"; // Free, Starter, Pro, Enterprise
    public bool IsActive { get; set; } = true;
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    public DateTime UpdatedAt { get; set; } = DateTime.UtcNow;

    // Navigation properties
    public ICollection<Employee> Employees { get; set; } = new List<Employee>();
    public ICollection<WorkSite> WorkSites { get; set; } = new List<WorkSite>();
}
