import 'package:dio/dio.dart';

class CurrencyService {
  final Dio _dio = Dio();
  final String _apiUrl = "https://api.exchangerate-api.com/v4/latest/USD";

  Future<double> getUsdToInrRate() async {
    try {
      final response = await _dio.get(_apiUrl);
      if (response.statusCode == 200) {
        final data = response.data;
        final rates = data['rates'] as Map<String, dynamic>;
        return (rates['INR'] as num).toDouble();
      } else {
        throw Exception('Failed to load exchange rates');
      }
    } catch (e) {
      // Return a fallback rate in case of error
      return 83.0;
    }
  }
}
