import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String authId;
  final String email;
  final String fullName;
  final String? password;
  final String? profilePicture;
  final String? role;

  const AuthEntity({
    required this.authId,
    required this.email,
    required this.fullName,
    this.password,
    this.profilePicture,
    this.role,
  });

  @override
  List<Object?> get props => [authId, email, fullName, password, profilePicture, role];
}