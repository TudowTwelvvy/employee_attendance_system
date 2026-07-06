import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

/// AuthRemoteDataSource handles all authentication API calls.
// This is the "waiter" that takes orders from the repository and brings back responses from the API.
class AuthRemoteDataSource {
  final DioClient _dioClient = DioClient();

  /// Login with email and password
  /// For now i use a mock API. When my ASP.NET API is ready,
  /// change the endpoint to '/auth/login'.
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      // For testing with mock API, i'll simulate a successful response
      // In production, this would be:
      // final response = await _dioClient.post('/auth/login', data: request.toJson());

      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful response (replace with real API call)
      final mockResponse = {
        'success': true,
        'message': 'Login successful',
        'data': {
          'token': 'mock_jwt_token_12345',
          'refreshToken': 'mock_refresh_token_67890',
          'user': {
            'id': 'user_123',
            'email': request.email,
            'fullName': 'Lord Tumelo Twelvvy',
            'role': request.email.contains('admin') ? 'Admin' : 'Employee',
          },
        },
      };

      return LoginResponseModel.fromJson(mockResponse);
    } on DioException catch (e) {
      // Dio-specific errors (timeout, no connection, etc.)
      throw _handleDioError(e);
    } catch (e) {
      // Other errors
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  /// Register new user
  Future<LoginResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      // Simulate API delay
      await Future.delayed(const Duration(seconds: 2));

      // Mock successful response
      final mockResponse = {
        'success': true,
        'message': 'Registration successful',
        'data': {
          'token': 'mock_jwt_token_newuser',
          'refreshToken': 'mock_refresh_token_newuser',
          'user': {
            'id': 'user_new_456',
            'email': email,
            'fullName': fullName,
            'role': 'Employee',
          },
        },
      };

      return LoginResponseModel.fromJson(mockResponse);
    } on DioException catch (e) {
      throw _handleDioError(e);
    } catch (e) {
      throw Exception('Registration failed: ${e.toString()}');
    }
  }

  /// Handle Dio-specific errors
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
        return Exception('Connection timed out. Please try again.');
      case DioExceptionType.receiveTimeout:
        return Exception('Server took too long to respond.');
      case DioExceptionType.badResponse:
        // Server returned an error status code
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ?? 'Unknown error';
        return Exception('Server error ($statusCode): $message');
      case DioExceptionType.connectionError:
        return Exception('No internet connection.');
      default:
        return Exception('Network error: ${error.message}');
    }
  }
}
