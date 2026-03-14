import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock.dart';

abstract class IStockRepository {
  Future<Either<Failure, Stock>> getStock(String symbol);
  Future<Either<Failure, List<Stock>>> searchStocks(String query);
}
