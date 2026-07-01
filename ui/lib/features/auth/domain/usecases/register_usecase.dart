import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> execute({
    required String fullName,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    // Validation
    if (fullName.isEmpty) throw Exception('Name is required');
    if (email.isEmpty) throw Exception('Email is required');
    if (password.isEmpty) throw Exception('Password is required');
    if (password != confirmPassword) {
      throw Exception('Passwords do not match');
    }
    if (password.length < 8) {
      throw Exception('Password must be at least 8 characters');
    }

    return await _repository.register(fullName, email, password);
  }
}