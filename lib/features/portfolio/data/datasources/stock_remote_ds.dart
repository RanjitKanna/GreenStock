import 'package:dio/dio.dart';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/network/dio_client.dart';
import '../../domain/entities/stock.dart';
import '../models/stock_model.dart';

abstract class IStockRemoteDataSource {
  Future<Stock> getStock(String symbol);
  Future<List<Stock>> searchStocks(String query);
}

class StockRemoteDataSource implements IStockRemoteDataSource {
  StockRemoteDataSource({Dio? dio}) : _dio = dio ?? DioClient.instance.dio;
  final Dio _dio;

  @override
  Future<Stock> getStock(String symbol) async {
    try {
      final response = await _dio.get('', queryParameters: {
        'function': 'GLOBAL_QUOTE',
        'symbol': symbol,
        'apikey': ApiConstants.alphaVantageKey,
      });
      final data = response.data as Map<String, dynamic>;

      if (data.containsKey('Note') || data.containsKey('Information')) {
        return StockModel.demo(symbol);
      }

      final quote = data['Global Quote'] as Map<String, dynamic>?;
      if (quote == null || quote.isEmpty) return StockModel.demo(symbol);

      return StockModel.fromAlphaVantage(data, symbol);
    } on DioException catch (e) {
      throw NetworkFailure('${e.message}');
    } catch (_) {
      return StockModel.demo(symbol);
    }
  }

  @override
  Future<List<Stock>> searchStocks(String query) async {
    if (query.isEmpty) return [];
    try {
      final response = await _dio.get('', queryParameters: {
        'function': 'SYMBOL_SEARCH',
        'keywords': query,
        'apikey': ApiConstants.alphaVantageKey,
      });
      final data = response.data as Map<String, dynamic>;
      if (data.containsKey('Note') || data.containsKey('Information')) {
        return _localSearch(query);
      }
      final bestMatches = data['bestMatches'] as List<dynamic>? ?? [];
      if (bestMatches.isEmpty) return _localSearch(query);
      return bestMatches
          .map((e) => StockModel.fromSearch(e as Map<String, dynamic>))
          .take(10)
          .toList();
    } catch (_) {
      return _localSearch(query);
    }
  }

  List<Stock> _localSearch(String query) {
    final q = query.toLowerCase();
    return StockModel.allKnownSymbols
        .where((s) =>
            s.symbol.toLowerCase().contains(q) ||
            s.name.toLowerCase().contains(q))
        .take(10)
        .toList();
  }
}
