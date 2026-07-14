using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using EmployeeAttendance.Application.Interfaces.Repositories;
using EmployeeAttendance.Domain.Entities;
using EmployeeAttendance.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

namespace EmployeeAttendance.Infrastructure.Repositories
{
    public class WorkSiteRepository : IWorkSiteRepository
    {
        // Same dependency pattern as EmployeeRepository
        private readonly ApplicationDbContext _dbContext;

        public WorkSiteRepository(ApplicationDbContext dbContext)
        {
            _dbContext = dbContext;
        }
        public async Task<WorkSite?> GetByCompanyIdAsync(Guid companyId)
        {
            return await _dbContext.WorkSites
                .FirstOrDefaultAsync(ws => ws.CompanyId == companyId);
        }

        public async Task<WorkSite?> GetByQrCodeValueAsync(string qrCodeValue)
        {
            return await _dbContext.WorkSites
                .FirstOrDefaultAsync(ws => ws.QrCodeValue == qrCodeValue);
        }
    }
}