using Microsoft.EntityFrameworkCore;
using EmployeeAttendance.Domain.Entities;
using Microsoft.AspNetCore.Identity.EntityFrameworkCore;
using EmployeeAttendance.Infrastructure.Identity;
using Microsoft.AspNetCore.Identity;

namespace EmployeeAttendance.Infrastructure.Data;

/// <summary>
/// ApplicationDbContext is the bridge between our C# code and the database. </summary>
public class ApplicationDbContext : IdentityDbContext<ApplicationUser>
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

        // Configure Identity table names
        modelBuilder.Entity<ApplicationUser>().ToTable("AspNetUsers");
        modelBuilder.Entity<IdentityRole>().ToTable("AspNetRoles");
        modelBuilder.Entity<IdentityUserRole<string>>().ToTable("AspNetUserRoles");
        modelBuilder.Entity<IdentityUserClaim<string>>().ToTable("AspNetUserClaims");
        modelBuilder.Entity<IdentityUserLogin<string>>().ToTable("AspNetUserLogins");
        modelBuilder.Entity<IdentityRoleClaim<string>>().ToTable("AspNetRoleClaims");
        modelBuilder.Entity<IdentityUserToken<string>>().ToTable("AspNetUserTokens");
    }
}