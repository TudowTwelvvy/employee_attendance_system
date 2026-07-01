import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:ui/core/storage/secure_storage.dart';


class DioClient {
  // Singleton pattern.. only one instance exists
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;
  DioClient._internal();

  // The Dio instance.. our HTTP client
  late final Dio dio;

  // Base URL for all API calls
  static const String baseUrl = 'https://localhost:5001/api';

  // Initialize Dio
  void initialize() {
    dio = Dio(
      BaseOptions(
        // Base URL - prepended to all requests
        // '/auth/login' becomes 'https://localhost:5001/api/auth/login'
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        
        receiveTimeout: const Duration(seconds: 30),
        
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
    // Logging interceptor - logs all requests and responses
    // Only in debug mode (not in production)
    if (kDebugMode) {
      dio.interceptors.add(
        LogInterceptor(
          request: true,      // Log request URL and method
          requestHeader: true, // Log request headers
          requestBody: true,   // Log request body (data)
          responseHeader: true,// Log response headers
          responseBody: true,  // Log response body
          error: true,         // Log errors
        ),
      );
    }

    // Auth interceptor - adds JWT token to every request
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // This runs BEFORE every request
          // Get token from secure storage
          final token = await SecureStorage.getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          return handler.next(options);  // Continue with the request
        },
        
        onResponse: (response, handler) {
          // This runs AFTER every successful response
          // We can transform data here if needed
          return handler.next(response);  // Continue with the response
        },
        
        onError: (error, handler) async {
          // If token expired (401), try to refresh
          if (error.response?.statusCode == 401) {
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retry original request with new token
              return handler.resolve(await dio.fetch(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  // Refresh the access token using refresh token
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await SecureStorage.getRefreshToken();
      if (refreshToken == null) return false;

      final response = await dio.post(
        '/auth/refresh',
        data: {'refreshToken': refreshToken},
      );

      final newAccessToken = response.data['accessToken'];
      final newRefreshToken = response.data['refreshToken'];

      await SecureStorage.setAccessToken(newAccessToken);
      await SecureStorage.setRefreshToken(newRefreshToken);

      return true;
    } catch (e) {
      // Refresh failed - user must login again
      await SecureStorage.clearAll();
      return false;
    }
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