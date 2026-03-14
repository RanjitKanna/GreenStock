import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/portfolio_stock.dart';
import '../repositories/i_portfolio_repository.dart';

class GetPortfolio {
  const GetPortfolio(this._repository);
  final IPortfolioRepository _repository;

  Future<Either<Failure, List<PortfolioStock>>> call() =>
      _repository.getPortfolio();
}

class AddToPortfolio {
  const AddToPortfolio(this._repository);
  final IPortfolioRepository _repository;

  Future<Either<Failure, Unit>> call(
    String symbol,
    double quantity,
    double purchasePrice,
  ) =>
      _repository.addStock(symbol.toUpperCase().trim(), quantity, purchasePrice);
}

class RemoveFromPortfolio {
  const RemoveFromPortfolio(this._repository);
  final IPortfolioRepository _repository;

  Future<Either<Failure, Unit>> call(String symbol) =>
      _repository.removeStock(symbol.toUpperCase().trim());
}
