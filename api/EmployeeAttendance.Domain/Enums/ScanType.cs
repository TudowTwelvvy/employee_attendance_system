using System.Text.Json.Serialization;

namespace EmployeeAttendance.Domain.Enums;

[JsonConverter(typeof(JsonStringEnumConverter))]
public enum ScanType
{
    CheckIn = 1,
    CheckOut = 2
}