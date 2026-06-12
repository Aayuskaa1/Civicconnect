import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:civic_connect/app.dart';
import 'package:civic_connect/core/services/hive/hive_service.dart';
import 'package:civic_connect/features/auth/presentation/view_model/auth_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final hiveService = HiveService();
  await hiveService.init();
  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const App(),
    ),
  );
}
