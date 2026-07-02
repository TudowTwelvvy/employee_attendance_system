import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class DioClient {
  // Only ONE instance of DioClient exists in the entire app
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  // The Dio instance — our HTTP client
  late final Dio dio;

  // Base URL — change this to my actual API URL, but for testing, we use a mock API
  static const String baseUrl = 'https://jsonplaceholder.typicode.com';
  // When my ASP.NET API is ready, i will change to:
  // static const String baseUrl = 'https://localhost:5001/api';

  /// Initialize Dio with configuration
  void initialize() {
    dio = Dio(
      BaseOptions(
        // Base URL — prepended to all requests
        // '/auth/login' becomes 'https://localhost:5001/api/auth/login'
        baseUrl: baseUrl,
        
        // Connection timeout — how long to wait when establishing connection
        connectTimeout: const Duration(seconds: 30),
        
        // Receive timeout — how long to wait for response data
        receiveTimeout: const Duration(seconds: 30),
        
        // Default headers for ALL requests
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Add interceptors (middleware for requests and responses)
    _setupInterceptors();
  }

  /// Configure interceptors for logging and auth
  void _setupInterceptors() {
    // Logging interceptor — logs all requests and responses
    // Only in debug mode (not in production)
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,        // Log request URL and method
          requestHeader: true,  // Log request headers
          requestBody: true,     // Log request body (data)
          responseHeader: true, // Log response headers
          responseBody: true,    // Log response body
          error: true,           // Log errors
        ),
      );
    }

    // Auth interceptor — adds JWT token to every request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // This runs BEFORE every request
          // We'll add JWT token here 
          // For now, no token needed for mock API
          
          return handler.next(options); // Continue with the request
        },
        
        onResponse: (response, handler) {
          // This runs AFTER every successful response
          return handler.next(response); // Continue with the response
        },
        
        onError: (error, handler) {
          // This runs when a request fails
          return handler.next(error); // Continue with the error
        },
      ),
    );
  }

  /// GET request
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await dio.get(path, queryParameters: queryParameters);
  }

  /// POST request
  Future<Response> post(
    String path, {
    dynamic data,
  }) async {
    return await dio.post(path, data: data);
  }

  /// PUT request
  Future<Response> put(
    String path, {
    dynamic data,
  }) async {
    return await dio.put(path, data: data);
  }

  /// DELETE request
  Future<Response> delete(String path) async {
    return await dio.delete(path);
  }
}