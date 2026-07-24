import 'package:dio/dio.dart';
import 'package:civic_connect/core/api/api_client.dart';
import 'package:civic_connect/core/api/api_endpoints.dart';
import 'package:civic_connect/features/reports/data/datasources/report_datasource.dart';
import 'package:civic_connect/features/reports/data/models/report_api_model.dart';
import 'package:civic_connect/features/reports/domain/entities/report_entity.dart';

class ReportRemoteDatasourceImpl implements ReportRemoteDatasource {
  final ApiClient _apiClient;

  ReportRemoteDatasourceImpl(this._apiClient);

  @override
  Future<List<ReportEntity>> getReports() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.complaints);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => ReportApiModel.fromJson(json as Map<String, dynamic>).toEntity()).toList();
      }
      throw Exception('Failed to load reports');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<List<ReportEntity>> getMyReports(String userId) async {
    try {
      // Shared API: GET /complaints/me (token identifies user; userId unused)
      final response = await _apiClient.get(ApiEndpoints.myComplaints);
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>;
        return data.map((json) => ReportApiModel.fromJson(json as Map<String, dynamic>).toEntity()).toList();
      }
      throw Exception('Failed to load user reports');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ReportEntity> submitReport(ReportEntity report, String? imagePath) async {
    try {
      final dataMap = {
        'title': report.title,
        'description': report.description,
        'category': report.category,
        'location': report.location,
        'submittedBy': report.submittedBy,
        'status': report.status,
        'createdAt': report.createdAt.toIso8601String(),
      };

      Response response;
      if (imagePath != null && imagePath.isNotEmpty) {
        final formData = FormData.fromMap({
          ...dataMap,
          'image': await MultipartFile.fromFile(imagePath, filename: imagePath.split('/').last),
        });
        response = await _apiClient.post(ApiEndpoints.complaints, data: formData);
      } else {
        response = await _apiClient.post(ApiEndpoints.complaints, data: dataMap);
      }

      if (response.statusCode == 201 || response.statusCode == 200) {
        final resData = response.data['data'] as Map<String, dynamic>;
        return ReportApiModel.fromJson(resData).toEntity();
      }
      throw Exception('Failed to submit report');
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<ReportEntity> updateReportStatus(String reportId, String status) async {
    try {
      final response = await _apiClient.patch(
        ApiEndpoints.updateComplaintAdmin(reportId),
        data: {'status': status},
      );
      if (response.statusCode == 200) {
        final resData = response.data['data'] as Map<String, dynamic>;
        return ReportApiModel.fromJson(resData).toEntity();
      }
      throw Exception('Failed to update report status');
    } catch (e) {
      rethrow;
    }
  }
}
