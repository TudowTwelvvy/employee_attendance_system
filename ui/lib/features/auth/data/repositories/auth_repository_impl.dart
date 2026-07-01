import '../../../../core/storage/secure_storage.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/login_request_model.dart';

/// AuthRepositoryImpl implements the AuthRepository contract.
/// 
/// It connects the Domain layer (business logic) with the Data layer (API calls).
/// This is where the actual work happens.
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<UserEntity> login(String email, String password) async {
    // Create request model
    final request = LoginRequestModel(
      email: email,
      password: password,
    );

    // Call API through data source
    final response = await _remoteDataSource.login(request);

    // Store tokens securely
    await SecureStorage.setAccessToken(response.token);
    await SecureStorage.setRefreshToken(response.refreshToken);
    await SecureStorage.setUserId(response.user.id);

    // Convert model to entity and return
    return response.user.toEntity();
  }

  @override
  Future<UserEntity> register(
    String fullName,
    String email,
    String password,
  ) async {
    final response = await _remoteDataSource.register(
      fullName: fullName,
      email: email,
      password: password,
    );

    await SecureStorage.setAccessToken(response.token);
    await SecureStorage.setRefreshToken(response.refreshToken);
    await SecureStorage.setUserId(response.user.id);

    return response.user.toEntity();
  }

  @override
  Future<void> logout() async {
    await SecureStorage.clearAll();
  }

  @override
  Future<bool> isLoggedIn() async {
    final token = await SecureStorage.getAccessToken();
    return token != null && token.isNotEmpty;
  }

  @override
  Future<UserEntity?> getCurrentUser() async {
    final userId = await SecureStorage.getUserId();
    if (userId == null) return null;

    // In a real app, you'd fetch user data from API
    // For now, return a placeholder
    return UserEntity(
      id: userId,
      email: '',
      fullName: '',
      role: 'Employee',
    );
  }
}