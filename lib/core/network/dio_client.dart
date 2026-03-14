import 'package:dio/dio.dart';
import '../constants/api_constants.dart';

class DioClient {
  DioClient._() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConstants.alphaVantageBase,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    )..interceptors.addAll([
        LogInterceptor(
          requestBody: false,
          responseBody: false,
          logPrint: (o) => debugPrint(o.toString()),
        ),
      ]);
  }

  static final DioClient _instance = DioClient._();
  static DioClient get instance => _instance;

  late final Dio _dio;
  Dio get dio => _dio;
}

void debugPrint(String msg) {
  // ignore: avoid_print
  print('[DioClient] $msg');
}
