import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:civic_connect/app.dart';
import 'package:civic_connect/core/providers/shared_prefs_provider.dart';
import 'package:civic_connect/core/api/api_endpoints.dart';
import 'package:civic_connect/core/services/hive/hive_services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(statusBarColor: Colors.transparent),
  );
  
  final hiveServices = HiveServices();
  await hiveServices.init();
  
  final sharedPreferences = await SharedPreferences.getInstance();
  
  // Log the resolved API base URL for debugging on physical devices
  // This helps verify whether the app is pointing at the LAN IP or localhost
  // when launched on a real device.
  // ignore: avoid_print
  print('Resolved API baseUrl: ${ApiEndpoints.baseUrl}');

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const App(),
    ),
  );
}
