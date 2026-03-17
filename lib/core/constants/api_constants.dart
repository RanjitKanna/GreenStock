import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConstants {
  ApiConstants._();

  static String get alphaVantageKey => dotenv.get('ALPHA_VANTAGE_KEY', fallback: '');
  static String get alphaVantageBase => dotenv.get('ALPHA_VANTAGE_BASE', fallback: '');
}
