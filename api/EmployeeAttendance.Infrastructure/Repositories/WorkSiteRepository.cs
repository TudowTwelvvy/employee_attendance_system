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
        public async Task<WorkSite?> GetByIdAsync(Guid id)
        {
            return await _dbContext.WorkSites
                .AsNoTracking()
                .FirstOrDefaultAsync(w => w.Id == id);
        }

        public async Task<WorkSite?> GetByQrCodeValueAsync(string qrCodeValue)
        {
            return await _dbContext.WorkSites
                .AsNoTracking()
                .FirstOrDefaultAsync(w => w.QrCodeValue == qrCodeValue);
        }

        public async Task<List<WorkSite>> GetByCompanyIdAsync(Guid companyId)
        {
            return await _dbContext.WorkSites
                .AsNoTracking()
                .Where(w => w.CompanyId == companyId)
                .ToListAsync();
        }

        public async Task<WorkSite> CreateAsync(WorkSite workSite)
        {
            _dbContext.WorkSites.Add(workSite);
            await _dbContext.SaveChangesAsync();
            return workSite;
        }

        public async Task UpdateAsync(WorkSite workSite)
        {
            _dbContext.WorkSites.Update(workSite);
            await _dbContext.SaveChangesAsync();
        }
    }
}