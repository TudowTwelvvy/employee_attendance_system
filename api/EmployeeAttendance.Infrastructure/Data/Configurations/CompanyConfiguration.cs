using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Infrastructure.Data.Configurations;

public class CompanyConfiguration : IEntityTypeConfiguration<Company>
{
    public void Configure(EntityTypeBuilder<Company> builder)
    {
        // Primary key
        builder.HasKey(c => c.Id);

        // Property configurations
        builder.Property(c => c.Name)
            .IsRequired()                    // NOT NULL
            .HasMaxLength(200);              // NVARCHAR(200)

        builder.Property(c => c.Email)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(c => c.Address)
            .HasMaxLength(500);              // Nullable by default

        builder.Property(c => c.Phone)
            .HasMaxLength(20);

        builder.Property(c => c.LogoUrl)
            .HasMaxLength(500);

        builder.Property(c => c.SubscriptionPlan)
            .HasMaxLength(50)
            .HasDefaultValue("Free");

        builder.Property(c => c.IsActive)
            .HasDefaultValue(true);

        builder.Property(c => c.CreatedAt)
            .HasDefaultValueSql("GETUTCDATE()");

        builder.Property(c => c.UpdatedAt)
            .HasDefaultValueSql("GETUTCDATE()");

        // Indexes
        builder.HasIndex(c => c.Email)
            .IsUnique();                     // No duplicate emails

        // Table name (optional — defaults to class name)
        builder.ToTable("Companies");
    }
}