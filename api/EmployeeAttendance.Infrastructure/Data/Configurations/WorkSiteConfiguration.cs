using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Infrastructure.Data.Configurations;

public class WorkSiteConfiguration : IEntityTypeConfiguration<WorkSite>
{
    public void Configure(EntityTypeBuilder<WorkSite> builder)
    {
        builder.HasKey(w => w.Id);

        builder.Property(w => w.Name)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(w => w.Address)
            .HasMaxLength(500);

        builder.Property(w => w.Latitude)
            .HasPrecision(10, 8);             // DECIMAL(10,8)

        builder.Property(w => w.Longitude)
            .HasPrecision(11, 8);             // DECIMAL(11,8)

        builder.Property(w => w.QrCodeValue)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(w => w.RadiusMeters)
            .HasDefaultValue(100);

        builder.Property(w => w.Description)
            .HasMaxLength(500);

        // Relationships
        builder.HasOne(w => w.Company)
            .WithMany(c => c.WorkSites)
            .HasForeignKey(w => w.CompanyId)
            .OnDelete(DeleteBehavior.Cascade);

        // Indexes
        builder.HasIndex(w => w.CompanyId);
        builder.HasIndex(w => w.QrCodeValue).IsUnique();

        builder.ToTable("WorkSites");
    }
}