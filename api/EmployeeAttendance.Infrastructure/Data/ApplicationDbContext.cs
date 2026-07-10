using Microsoft.EntityFrameworkCore;
using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Infrastructure.Data;

/// <summary>
/// ApplicationDbContext is the bridge between our C# code and the database. </summary>
public class ApplicationDbContext : DbContext
{
    public DbSet<Company> Companies { get; set; } = null!;
    public DbSet<Employee> Employees { get; set; } = null!;
    public DbSet<WorkSite> WorkSites { get; set; } = null!;
    public DbSet<AttendanceRecord> AttendanceRecords { get; set; } = null!;

    // Constructor — ASP.NET Core injects options automatically
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    // Configure entity relationships, constraints, indexes
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);

        // Apply all configuration classes from this assembly
        // This scans for classes that implement IEntityTypeConfiguration<T>
        modelBuilder.ApplyConfigurationsFromAssembly(typeof(ApplicationDbContext).Assembly);
    }
}