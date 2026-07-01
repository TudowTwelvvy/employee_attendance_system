import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

/// LoginUseCase represents the "Login" action in the app.
class LoginUseCase {
  final AuthRepository _repository;

  LoginUseCase(this._repository);

  /// Execute the login use case
  Future<UserEntity> execute(String email, String password) async {
    // Validate input (business rule)
    if (email.isEmpty) {
      throw Exception('Email is required');
    }
    if (password.isEmpty) {
      throw Exception('Password is required');
    }
    if (!email.contains('@')) {
      throw Exception('Invalid email format');
    }

    // Call repository
    return await _repository.login(email, password);
  }
}