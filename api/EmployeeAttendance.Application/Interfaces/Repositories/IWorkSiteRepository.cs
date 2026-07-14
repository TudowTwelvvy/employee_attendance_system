using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Application.Interfaces.Repositories
{
    public interface IWorkSiteRepository
    {
        Task<WorkSite?> GetByIdAsync(Guid id);
        Task<WorkSite?> GetByQrCodeValueAsync(string qrCodeValue);
        Task<List<WorkSite>> GetByCompanyIdAsync(Guid companyId);
        Task<WorkSite> CreateAsync(WorkSite workSite);
        Task UpdateAsync(WorkSite workSite);
    }
}