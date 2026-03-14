import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'features/main/green_stock.dart';
import 'core/di/service_locator.dart' as sl;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await sl.init();
  runApp(const GreenStockApp());
}
