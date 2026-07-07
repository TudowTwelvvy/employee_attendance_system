import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'app.dart';

void main() {
  // Initialize Dio before app starts
  //DioClient().initialize();

  // Only initialize mobile-specific services on non-web platforms
  if (!kIsWeb) {
    DioClient().initialize();
  }

  runApp(ProviderScope(child: const App()));
}
