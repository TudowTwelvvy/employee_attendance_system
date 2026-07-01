import 'package:dio/dio.dart';
import '../../../../core/network/dio_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';

class AuthRemoteDataSource {
  final DioClient _dioClient = DioClient();

  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await _dioClient.post(
        '/auth/login',
        data: request.toJson(),
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<LoginResponseModel> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _dioClient.post(
        '/auth/register',
        data: {
          'fullName': fullName,
          'email': email,
          'password': password,
        },
      );

      return LoginResponseModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException error) {
    if (error.response != null) {
      final message = error.response?.data?['message'] ?? 'Unknown error';
      return Exception(message);
    }
    return Exception('Network error: ${error.message}');
  }
}