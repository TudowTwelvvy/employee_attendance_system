using System.Net;
using System.Text.Json;

namespace EmployeeAttendance.API.Middleware;

/// <summary>
/// ExceptionMiddleware catches ALL unhandled exceptions in the application.
/// 
/// Without this:
/// - Development: ASP.NET Core shows an ugly error page
/// - Production: Blank 500 response with no details
/// 
/// With this:
/// - ALL environments return consistent JSON: { success: false, message: "...", statusCode: 500 }
/// - Flutter can always parse the response the same way
/// </summary>
public class ExceptionMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<ExceptionMiddleware> _logger;

    public ExceptionMiddleware(RequestDelegate next, ILogger<ExceptionMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        try
        {
            // Pass the request to the next middleware/controller
            await _next(context);
        }
        catch (Exception ex)
        {
            // Something went wrong! Handle it gracefully
            _logger.LogError(ex, "Unhandled exception occurred");
            await HandleExceptionAsync(context, ex);
        }
    }

    private static Task HandleExceptionAsync(HttpContext context, Exception exception)
    {
        // Determine status code based on exception type
        var statusCode = exception switch
        {
            UnauthorizedAccessException => HttpStatusCode.Unauthorized,    // 401
            InvalidOperationException => HttpStatusCode.BadRequest,        // 400
            ArgumentException => HttpStatusCode.BadRequest,                 // 400
            KeyNotFoundException => HttpStatusCode.NotFound,               // 404
            _ => HttpStatusCode.InternalServerError                        // 500

        };

        // Build consistent error response
        var response = new
        {
            Success = false,
            Message = exception.Message,
            StatusCode = (int)statusCode,
            // In development, include stack trace for debugging
            StackTrace = context.RequestServices.GetRequiredService<IWebHostEnvironment>().IsDevelopment()
                ? exception.StackTrace
                : null
        };

        // Set response properties
        context.Response.ContentType = "application/json";
        context.Response.StatusCode = (int)statusCode;

        // Serialize and write response
        var json = JsonSerializer.Serialize(response, new JsonSerializerOptions
        {
            PropertyNamingPolicy = JsonNamingPolicy.CamelCase
        });

        return context.Response.WriteAsync(json);
    }
}