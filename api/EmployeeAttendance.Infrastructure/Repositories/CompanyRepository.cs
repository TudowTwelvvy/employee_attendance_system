using Microsoft.EntityFrameworkCore;
using EmployeeAttendance.Application.Interfaces.Repositories;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Infrastructure.Data;

namespace EmployeeAttendance.Infrastructure.Repositories;

public class CompanyRepository : ICompanyRepository
{
    private readonly ApplicationDbContext _dbContext;

    public CompanyRepository(ApplicationDbContext dbContext)
    {
        _dbContext = dbContext;
    }

    public async Task<Company?> GetByIdAsync(Guid id)
    {
        return await _dbContext.Companies
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Id == id);
    }

    public async Task<Company?> GetByEmailAsync(string email)
    {
        return await _dbContext.Companies
            .AsNoTracking()
            .FirstOrDefaultAsync(c => c.Email == email);
    }

    public async Task<Company> CreateAsync(Company company)
    {
        _dbContext.Companies.Add(company);
        await _dbContext.SaveChangesAsync();
        return company;
    }

    public async Task<bool> ExistsByEmailAsync(string email)
    {
        return await _dbContext.Companies
            .AnyAsync(c => c.Email == email);
    }
}