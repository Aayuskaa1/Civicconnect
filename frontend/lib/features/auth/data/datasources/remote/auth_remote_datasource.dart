import 'package:civic_connect/core/api/api_service.dart';
import 'package:civic_connect/core/constants/api_endpoints.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

abstract class IAuthRemoteDataSource {
  Future<bool> register(AuthEntity entity);
  Future<Map<String, dynamic>> login(String email, String password);
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final ApiService _apiService;

  AuthRemoteDataSource({required ApiService apiService}) : _apiService = apiService;

  @override
  Future<bool> register(AuthEntity entity) async {
    try {
      final nameParts = entity.fullName.trim().split(' ');
      final firstName = nameParts.isNotEmpty ? nameParts.first : '';
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '.';

      final response = await _apiService.post(
        ApiEndpoints.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': entity.email,
          'username': entity.username.toLowerCase().replaceAll(' ', ''),
          'password': entity.password,
          'phoneNumber': entity.phoneNumber,
          'report': entity.report,
        },
      );
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      }
      return false;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiService.post(
        ApiEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }
      throw Exception('Login failed');
    } catch (e) {
      rethrow;
    }
  }
}
