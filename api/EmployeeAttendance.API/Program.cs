using EmployeeAttendance.Infrastructure.Data;
using Microsoft.EntityFrameworkCore;

using DotNetEnv;

Env.Load();

var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY");

var issuer = Environment.GetEnvironmentVariable("JWT_ISSUER");

var audience = Environment.GetEnvironmentVariable("JWT_AUDIENCE");

var expiryMinutes = int.Parse(
    Environment.GetEnvironmentVariable("JWT_EXPIRY_MINUTES")!);

var builder = WebApplication.CreateBuilder(args);

// Add services to the container
builder.Services.AddControllers();

// Configure EF Core with SQL Server
builder.Services.AddDbContext<ApplicationDbContext>(options =>
{
    options.UseSqlServer(
        builder.Configuration.GetConnectionString("DefaultConnection"),
        sqlOptions =>
        {
            // Retry on transient failures (network blips)
            sqlOptions.EnableRetryOnFailure(
                maxRetryCount: 3,
                maxRetryDelay: TimeSpan.FromSeconds(30),
                errorNumbersToAdd: null);
        });
});

// Learn more about configuring Swagger/OpenAPI at https://aka.ms/aspnetcore/swashbuckle
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

var app = builder.Build();

// Configure the HTTP request pipeline
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();