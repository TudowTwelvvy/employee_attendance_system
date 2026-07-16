using System.Diagnostics;

namespace EmployeeAttendance.API.Middleware;

/// <summary>
/// RequestResponseLoggingMiddleware logs every HTTP request and response.
/// 
/// Useful for:
/// - Debugging: "What did the Flutter app send?"
/// - Auditing: "Who accessed what and when?"
/// - Performance: "How long did this request take?"
/// </summary>
public class RequestResponseLoggingMiddleware
{
    private readonly RequestDelegate _next;
    private readonly ILogger<RequestResponseLoggingMiddleware> _logger;

    public RequestResponseLoggingMiddleware(RequestDelegate next, ILogger<RequestResponseLoggingMiddleware> logger)
    {
        _next = next;
        _logger = logger;
    }

    public async Task InvokeAsync(HttpContext context)
    {
        // Start timer
        var stopwatch = Stopwatch.StartNew();

        // Log incoming request
        _logger.LogInformation(
            "Request {Method} {Path} from {IP} started",
            context.Request.Method,
            context.Request.Path,
            context.Connection.RemoteIpAddress);

        // Capture the response body (by default it's write-only)
        var originalBodyStream = context.Response.Body;
        using var responseBody = new MemoryStream();
        context.Response.Body = responseBody;

        try
        {
            // Process the request
            await _next(context);
        }
        finally
        {
            // Reset response body position to read it
            responseBody.Position = 0;

            // Read response body
            var responseText = await new StreamReader(responseBody).ReadToEndAsync();

            // Log response
            _logger.LogInformation(
                "Request {Method} {Path} completed in {ElapsedMs}ms with status {StatusCode}",
                context.Request.Method,
                context.Request.Path,
                stopwatch.ElapsedMilliseconds,
                context.Response.StatusCode);

            // Copy response back to original stream so client receives it
            responseBody.Position = 0;
            await responseBody.CopyToAsync(originalBodyStream);
            context.Response.Body = originalBodyStream;
        }
    }
}