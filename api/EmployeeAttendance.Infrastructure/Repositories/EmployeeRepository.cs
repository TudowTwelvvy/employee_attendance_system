using Microsoft.EntityFrameworkCore;
using EmployeeAttendance.Application.Interfaces.Repositories;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Infrastructure.Data;

namespace EmployeeAttendance.Infrastructure.Repositories;

public class EmployeeRepository : IEmployeeRepository
{
    private readonly ApplicationDbContext _context;

    public EmployeeRepository(ApplicationDbContext context)
    {
        _context = context;
    }


    // Get employee by their unique ID
    public async Task<Employee?> GetByIdAsync(Guid id)
    {
        return await _context.Employees.FindAsync(id);
    }

    /// Get employee by their ASP.NET Identity UserId
    /// EF Core translation: SELECT TOP 1 * FROM Employees WHERE UserId = @userId
    public async Task<Employee?> GetByUserIdAsync(string userId)
    {
        return await _context.Employees
            .FirstOrDefaultAsync(e => e.UserId == userId);
    }

    /// Get employee by email
    public async Task<Employee?> GetByEmailAsync(string email)
    {
        return await _context.Employees
            .FirstOrDefaultAsync(e => e.Email == email);
    }


    /// Get all employees belonging to a company 
    /// EF Core translation: SELECT * FROM Employees WHERE CompanyId = @companyId
    public async Task<List<Employee>> GetByCompanyIdAsync(Guid companyId)
    {
        // ToListAsync = execute query and return results as List
        return await _context.Employees
            .Where(e => e.CompanyId == companyId)
            .ToListAsync();
    }


    /// Create a new employee
    public async Task<Employee> CreateAsync(Employee employee)
    {
        _context.Employees.Add(employee);

        await _context.SaveChangesAsync();

        return employee;
    }


    /// Update an existing employee
    public async Task<Employee> UpdateAsync(Employee employee)
    {

        _context.Employees.Update(employee);

        await _context.SaveChangesAsync();

        return employee;
    }

    /// Check if an employee with this email already exists
    public async Task<bool> ExistsAsync(string email)
    {
        // AnyAsync = returns true if ANY record matches the condition
        return await _context.Employees
            .AnyAsync(e => e.Email == email);
    }
}