using Microsoft.EntityFrameworkCore;
using Microsoft.EntityFrameworkCore.Metadata.Builders;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Domain.Enums;

namespace EmployeeAttendance.Infrastructure.Data.Configurations;

public class AttendanceRecordConfiguration : IEntityTypeConfiguration<AttendanceRecord>
{
    public void Configure(EntityTypeBuilder<AttendanceRecord> builder)
    {
        builder.HasKey(a => a.Id);

        builder.Property(a => a.QrCodeValue)
            .IsRequired()
            .HasMaxLength(200);

        builder.Property(a => a.Latitude)
            .HasPrecision(10, 8);

        builder.Property(a => a.Longitude)
            .HasPrecision(11, 8);

        builder.Property(a => a.DistanceFromSite)
            .HasPrecision(10, 2);             // DECIMAL(10,2) — meters

        builder.Property(a => a.DeviceName)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(a => a.DeviceModel)
            .IsRequired()
            .HasMaxLength(100);

        builder.Property(a => a.OperatingSystem)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(a => a.OsVersion)
            .IsRequired()
            .HasMaxLength(50);

        builder.Property(a => a.AppVersion)
            .IsRequired()
            .HasMaxLength(20);

        builder.Property(a => a.ScanType)
            .HasConversion<string>()
            .HasMaxLength(20);

        builder.Property(a => a.Status)
            .HasConversion<string>()
            .HasMaxLength(20)
            .HasDefaultValue(AttendanceStatus.Valid);

        builder.Property(a => a.Notes)
            .HasMaxLength(500);

        // Relationships
        builder.HasOne(a => a.Employee)
            .WithMany(e => e.AttendanceRecords)
            .HasForeignKey(a => a.EmployeeId)
            .OnDelete(DeleteBehavior.Cascade);

        builder.HasOne(a => a.WorkSite)
            .WithMany(w => w.AttendanceRecords)
            .HasForeignKey(a => a.WorkSiteId)
            .OnDelete(DeleteBehavior.Restrict); // Don't delete site if records exist

        // Indexes for performance
        builder.HasIndex(a => a.EmployeeId);
        builder.HasIndex(a => a.WorkSiteId);
        builder.HasIndex(a => a.ScanDate);
        builder.HasIndex(a => new { a.EmployeeId, a.ScanDate }); // Composite index

        builder.ToTable("AttendanceRecords");
    }
}