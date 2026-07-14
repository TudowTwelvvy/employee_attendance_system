using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Application.Interfaces.Repositories
{
    public interface ICompanyRepository
    {
        Task<Company?> GetByIdAsync(Guid id);
        Task<Company?> GetByEmailAsync(string email);
        Task<Company> CreateAsync(Company company);
        Task<bool> ExistsByEmailAsync(string email);

    }
}