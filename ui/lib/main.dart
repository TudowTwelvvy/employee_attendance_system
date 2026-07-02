import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/network/dio_client.dart';
import 'app.dart';

void main() {
  // Initialize Dio before app starts
  DioClient().initialize();
  
  runApp(
    ProviderScope(
      child: const App(),
    ),
  );
}