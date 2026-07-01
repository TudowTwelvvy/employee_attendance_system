import '../entities/user_entity.dart';

abstract class AuthRepository {
  /// Login with email and password
  /// Returns UserEntity on success, throws Exception on failure
  Future<UserEntity> login(String email, String password);

  /// Register new user
  Future<UserEntity> register(
    String fullName,
    String email,
    String password,
  );

  /// Logout current user
  Future<void> logout();

  /// Check if user is currently logged in
  Future<bool> isLoggedIn();

  /// Get current user data
  Future<UserEntity?> getCurrentUser();
}