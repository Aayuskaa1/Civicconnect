import 'package:civic_connect/app/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(
    // ProviderScope stores the state of all Riverpod providers
    const ProviderScope(
      child: App(),
    ),
  );
}

