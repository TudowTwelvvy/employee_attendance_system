import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository _repository;

  RegisterUseCase(this._repository);

  Future<UserEntity> execute({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (fullName.isEmpty) {
      throw Exception('Name cannot be empty');
    }
    if (email.isEmpty || !email.contains('@')) {
      throw Exception('Invalid email');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters');
    }

    return await _repository.register(fullName, email, password);
  }
}