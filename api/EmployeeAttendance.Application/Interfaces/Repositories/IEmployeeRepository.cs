using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Application.Interfaces.Repositories;


/// Repository interface for Employee operations.
public interface IEmployeeRepository
{
    Task<Employee?> GetByIdAsync(Guid id);
    Task<Employee?> GetByUserIdAsync(string userId);
    Task<Employee?> GetByEmailAsync(string email);
    Task<List<Employee>> GetByCompanyIdAsync(Guid companyId);
    Task<Employee> CreateAsync(Employee employee);
    Task<Employee> UpdateAsync(Employee employee);
    Task<bool> ExistsAsync(string email);
}