using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Application.Interfaces.Services;


public interface IJwtTokenService
{
    string GenerateToken(string userId, string email, string userName, Guid? companyId, IList<string> roles);
    string GenerateRefreshToken();
}