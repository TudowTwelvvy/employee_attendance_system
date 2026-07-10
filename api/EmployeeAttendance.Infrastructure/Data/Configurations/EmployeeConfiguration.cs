using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Infrastructure.Data.Configurations;

public class EmployeeConfiguration : IEntityTypeConfiguration<Employee>
{
    public void Configure(EntityTypeBuilder<Employee> builder)
    {
        builder.HasKey(e => e.Id);

        builder.Property(e => e.UserId)
            .IsRequired()
            .HasMaxLength(450);              // Matches ASP.NET Identity

        builder.Property(e => e.FullName)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(e => e.Email)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(e => e.Phone)
            .HasMaxLength(20);

        builder.Property(e => e.EmployeeCode)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(e => e.Department)
            .HasMaxLength(100);

        builder.Property(e => e.Designation)
            .HasMaxLength(100);

        builder.Property(e => e.ProfilePictureUrl)
            .HasMaxLength(500);

        builder.Property(e => e.Role)
            .HasConversion<string>()          // Store enum as string in DB
            .HasMaxLength(50)
            .HasDefaultValue(UserRole.Employee);

        builder.Property(e => e.IsActive)
            .HasDefaultValue(true);

        // Relationships
        builder.HasOne(e => e.Company)        // Employee has ONE Company
            .WithMany(c => c.Employees)       // Company has MANY Employees
            .HasForeignKey(e => e.CompanyId)  // Foreign key
            .OnDelete(DeleteBehavior.Cascade); // Delete employees if company deleted

        // Indexes
        builder.HasIndex(e => e.CompanyId);
        builder.HasIndex(e => e.EmployeeCode).IsUnique();
        builder.HasIndex(e => e.UserId).IsUnique();

        builder.ToTable("Employees");
    }
}