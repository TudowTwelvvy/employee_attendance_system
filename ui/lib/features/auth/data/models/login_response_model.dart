import '../../domain/entities/user_entity.dart';


class LoginResponseModel {
  final bool success;
  final String message;
  final String token;
  final String refreshToken;
  final UserModel user;

  LoginResponseModel({
    required this.success,
    required this.message,
    required this.token,
    required this.refreshToken,
    required this.user,
  });

  //Create from JSON (API response)
  //The API returns nested JSON. We extract data from the 'data' key.
  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      token: json['data']['token'] ?? '',
      refreshToken: json['data']['refreshToken'] ?? '',
      user: UserModel.fromJson(json['data']['user']),
    );
  }
}

/// UserModel represents user data from API.is different from UserEntity
class UserModel {
  final String id;
  final String email;
  final String fullName;
  final String role;

  UserModel({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      fullName: json['fullName'] ?? '',
      role: json['role'] ?? 'Employee',
    );
  }

  /// Convert to Domain Entity... This is the bridge between Data layer and Domain layer.
  
  UserEntity toEntity() {
    return UserEntity(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
    );
  }
}