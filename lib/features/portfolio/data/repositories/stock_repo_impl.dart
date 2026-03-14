import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/stock.dart';
import '../../domain/repositories/i_stock_repository.dart';
import '../datasources/stock_remote_ds.dart';

class StockRepositoryImpl implements IStockRepository {
  const StockRepositoryImpl(this._remote);
  final IStockRemoteDataSource _remote;

  @override
  Future<Either<Failure, Stock>> getStock(String symbol) async {
    try {
      final stock = await _remote.getStock(symbol);
      return Right(stock);
    } on Failure catch (f) {
      return Left(f);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, List<Stock>>> searchStocks(String query) async {
    try {
      final results = await _remote.searchStocks(query);
      return Right(results);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }
}
