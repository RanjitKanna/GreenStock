import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock.dart';
import '../repositories/i_stock_repository.dart';

class GetStockPrice {
  const GetStockPrice(this._repository);
  final IStockRepository _repository;

  Future<Either<Failure, Stock>> call(String symbol) =>
      _repository.getStock(symbol.toUpperCase().trim());
}
