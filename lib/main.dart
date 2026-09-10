import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:green_stocks/services/notification_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/main/green_stock.dart';
import 'core/di/service_locator.dart' as sl;
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  final notificationService = NotificationService();
  notificationService.initialize();

  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await sl.init();
  runApp(const GreenStockApp());
}
