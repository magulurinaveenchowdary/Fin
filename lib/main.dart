import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'data/datasources/hive_datasource.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Notifications
  await NotificationService().init();

  // Initialize Hive local database
  final hiveDatasource = HiveDatasource();
  await hiveDatasource.init();

  runApp(
    const ProviderScope(
      child: FinVaultApp(),
    ),
  );
}
