import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

class AuthApiModel {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? role;
  final String? profilePicture;
  final String? username;

  AuthApiModel({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.role,
    this.profilePicture,
    this.username,
  });

  factory AuthApiModel.fromJson(Map<String, dynamic> json) {
    return AuthApiModel(
      id: json['_id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      role: json['role'] as String?,
      profilePicture: json['profilePicture'] as String?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'profilePicture': profilePicture,
      'username': username,
    };
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: id,
      email: email,
      fullName: '$firstName $lastName'.trim(),
      username: username,
      role: role,
      profilePicture: profilePicture,
    );
  }

  static AuthApiModel fromEntity(AuthEntity entity) {
    final names = entity.fullName.split(' ');
    final fName = names.isNotEmpty ? names.first : '';
    final lName = names.length > 1 ? names.sublist(1).join(' ') : '';
    return AuthApiModel(
      id: entity.authId,
      email: entity.email,
      firstName: fName,
      lastName: lName,
      role: entity.role,
      profilePicture: entity.profilePicture,
      username: entity.username,
    );
  }
}
