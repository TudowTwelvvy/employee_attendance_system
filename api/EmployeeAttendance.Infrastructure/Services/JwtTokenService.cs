using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using EmployeeAttendance.Infrastructure.Identity;

namespace EmployeeAttendance.Infrastructure.Services;


public class JwtTokenService
{
    private readonly IConfiguration _configuration;

    public JwtTokenService(IConfiguration configuration)
    {
        _configuration = configuration;
    }


    // Generate a JWT token for a user
    public string GenerateToken(ApplicationUser user, IList<string> roles)
    {
        // Get JWT settings from configuration
        var jwtSettings = _configuration.GetSection("JwtSettings");
        var secretKey = Environment.GetEnvironmentVariable("JWT_SECRET_KEY")!;
        var issuer = jwtSettings["Issuer"]!;
        var audience = jwtSettings["Audience"]!;
        var expiryMinutes = int.Parse(jwtSettings["ExpiryMinutes"]!);

        // Create security key from secret
        var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(secretKey));

        // Create signing credentials (HMAC-SHA256)
        var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

        //claims (data stored in the token)
        var claims = new List<Claim>
        {
            new Claim(JwtRegisteredClaimNames.Sub, user.Id),           // User ID
            new Claim(JwtRegisteredClaimNames.Email, user.Email!),      // Email
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString()), // Unique token ID
            new Claim("companyId", user.CompanyId?.ToString() ?? ""),   // Company ID
            new Claim("fullName", user.UserName ?? ""),               // Display name
        };

        // role claims
        foreach (var role in roles)
        {
            claims.Add(new Claim(ClaimTypes.Role, role));
        }

        // Create the token
        var token = new JwtSecurityToken(
            issuer: issuer,                    // Who issued the token
            audience: audience,               // Who can use it
            claims: claims,                   // Data inside token
            expires: DateTime.UtcNow.AddMinutes(expiryMinutes), // Expiry
            signingCredentials: credentials    // How to verify it's authentic
        );

        // Serialize to string
        return new JwtSecurityTokenHandler().WriteToken(token);
    }

    /// <summary>
    /// Generate a refresh token (long-lived, used to get new access tokens)
    /// </summary>
    public string GenerateRefreshToken()
    {
        // Simple random token for refresh
        return Convert.ToBase64String(Guid.NewGuid().ToByteArray());
    }
}