import 'package:equatable/equatable.dart';

class AuthEntity extends Equatable {
  final String userId;  
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? userRole; 
  final String username;
  final String? profilePicture;
  final String? department; 
  final String password;    
  final String report;    

  const AuthEntity({
    required this.userId,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.userRole,
    required this.username,
    this.profilePicture,
    this.department,
    required this.password,
    required this.report,
  });
  bool get isOfficial => userRole?.toLowerCase() == 'official';

  @override
  List<Object?> get props => [
        userId,
        fullName,
        email,
        phoneNumber,
        userRole,
        username,
        profilePicture,
        department,
      ];
}