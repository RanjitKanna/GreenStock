import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/portfolio_stock.dart';

abstract class IPortfolioRepository {
  Future<Either<Failure, List<PortfolioStock>>> getPortfolio();
  Future<Either<Failure, Unit>> addStock(String symbol, double quantity, double purchasePrice);
  Future<Either<Failure, Unit>> removeStock(String symbol);
  Future<Either<Failure, Unit>> updateQuantity(String symbol, double quantity);
}
