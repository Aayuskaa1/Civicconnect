import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0)
  final String authId;

  @HiveField(1)
  final String email;

  @HiveField(2)
  final String fullName;

  @HiveField(3)
  final String password;

  @HiveField(4)
  final String? profilePicture;

  @HiveField(5)
  final String? role;

  AuthHiveModel({
    String? authId,
    required this.email,
    required this.fullName,
    required this.password,
    this.profilePicture,
    this.role,
  }) : authId = authId ?? const Uuid().v4();

  factory AuthHiveModel.fromEntity(AuthEntity entity) {
    return AuthHiveModel(
      authId: entity.authId.isEmpty ? const Uuid().v4() : entity.authId,
      email: entity.email,
      fullName: entity.fullName,
      password: entity.password ?? '',
      profilePicture: entity.profilePicture,
      role: entity.role,
    );
  }

  AuthEntity toEntity() {
    return AuthEntity(
      authId: authId,
      email: email,
      fullName: fullName,
      password: password,
      profilePicture: profilePicture,
      role: role,
    );
  }
}
