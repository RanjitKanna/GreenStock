import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/portfolio_stock.dart';
import '../../domain/repositories/i_portfolio_repository.dart';
import '../datasources/esg_datasource.dart';
import '../datasources/portfolio_local_ds.dart';
import '../datasources/stock_remote_ds.dart';
import '../models/portfolio_entry_model.dart';

class PortfolioRepositoryImpl implements IPortfolioRepository {
  const PortfolioRepositoryImpl(this._local, this._stockDs, this._esgDs);

  final PortfolioLocalDataSource _local;
  final IStockRemoteDataSource _stockDs;
  final IEsgDataSource _esgDs;

  @override
  Future<Either<Failure, List<PortfolioStock>>> getPortfolio() async {
    try {
      final entries = await _local.getAll();
      final List<PortfolioStock> holdings = [];
      for (final entry in entries) {
        final stock = await _stockDs.getStock(entry.symbol);
        final esgData = await _esgDs.getEsgData(entry.symbol);
        holdings.add(PortfolioStock(
          stock: stock,
          esgData: esgData,
          quantity: entry.quantity,
          purchasePrice: entry.purchasePrice,
        ));
      }
      return Right(holdings);
    } catch (e) {
      return Left(CacheFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> addStock(
    String symbol,
    double quantity,
    double purchasePrice,
  ) async {
    try {
      await _local.save(
          PortfolioEntry(symbol: symbol, quantity: quantity, purchasePrice: purchasePrice));
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> removeStock(String symbol) async {
    try {
      await _local.delete(symbol);
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('$e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> updateQuantity(String symbol, double quantity) async {
    try {
      final entries = await _local.getAll();
      final existing = entries.firstWhere((e) => e.symbol == symbol,
          orElse: () => throw Exception('Not found'));
      await _local.save(PortfolioEntry(
        symbol: symbol,
        quantity: quantity,
        purchasePrice: existing.purchasePrice,
      ));
      return const Right(unit);
    } catch (e) {
      return Left(CacheFailure('$e'));
    }
  }
}
