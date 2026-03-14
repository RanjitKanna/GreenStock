import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/stock.dart';
import '../repositories/i_stock_repository.dart';

class SearchStocks {
  const SearchStocks(this._repository);
  final IStockRepository _repository;

  Future<Either<Failure, List<Stock>>> call(String query) => _repository.searchStocks(query.trim());
}
