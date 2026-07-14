using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EmployeeAttendance.Domain.Entities;

namespace EmployeeAttendance.Application.Interfaces.Repositories
{
    public interface IWorkSiteRepository
    {
        Task<WorkSite?> GetByCompanyIdAsync(Guid companyId);

        Task<WorkSite?> GetByQrCodeValueAsync(string qrCodeValue);
    }
}