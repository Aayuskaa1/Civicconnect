import 'package:civic_connect/core/api/api_client.dart';
import 'package:civic_connect/core/api/api_endpoints.dart';
import 'package:civic_connect/features/auth/data/datasources/auth_datasource.dart';
import 'package:civic_connect/features/auth/domain/entities/auth_entity.dart';

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final ApiClient _apiClient;

  AuthRemoteDatasourceImpl(this._apiClient);

  @override
  Future<bool> register(AuthEntity entity) async {
    try {
      final names = entity.fullName.split(' ');
      final firstName = names.isNotEmpty ? names.first : '';
      final lastName = names.length > 1 ? names.sublist(1).join(' ') : '.';

      final response = await _apiClient.post(
        ApiEndpoints.register,
        data: {
          'firstName': firstName,
          'lastName': lastName,
          'email': entity.email,
          'username': entity.email.split('@').first,
          'password': entity.password,
          'phoneNumber': '',
          'report': '',
        },
      );
      return response.statusCode == 201 || response.statusCode == 200;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _apiClient.post(
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
