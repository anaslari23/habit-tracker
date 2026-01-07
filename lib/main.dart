import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/services/firebase_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await FirebaseService.initialize();
  await NotificationService.initialize();

  runApp(
    const ProviderScope(
      child: HabitTrackerApp(),
    ),
  );
}
