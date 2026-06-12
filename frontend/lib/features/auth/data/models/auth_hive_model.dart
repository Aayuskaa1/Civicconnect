import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

part 'auth_hive_model.g.dart';

@HiveType(typeId: 0)
class AuthHiveModel extends HiveObject {
  @HiveField(0) final String authId;
  @HiveField(1) final String fullName;
  @HiveField(2) final String email;
  @HiveField(3) final String? phoneNumber;
  @HiveField(4) final String? role;
  @HiveField(5) final String username;
  @HiveField(6) final String? profilePicture;
  @HiveField(7) final String? department;
  @HiveField(8) final String password;
  @HiveField(9) final String report;

  AuthHiveModel({
    String? authId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.role,
    required this.username,
    this.profilePicture,
    this.department,
    required this.password,
    required this.report,
  }) : authId = authId ?? const Uuid().v4();

  factory AuthHiveModel.fromEntity(AuthEntity entity) => AuthHiveModel(
        authId: entity.userId.isEmpty ? null : entity.userId,
        fullName: entity.fullName,
        email: entity.email,
        phoneNumber: entity.phoneNumber,
        role: entity.userRole,
        username: entity.username,
        profilePicture: entity.profilePicture,
        department: entity.department,
        password: entity.password,
        report: entity.report,
      );

  AuthEntity toEntity() => AuthEntity(
        userId: authId,
        fullName: fullName,
        email: email,
        phoneNumber: phoneNumber,
        userRole: role,
        username: username,
        profilePicture: profilePicture,
        department: department,
        password: password,
        report: report,
      );
}
