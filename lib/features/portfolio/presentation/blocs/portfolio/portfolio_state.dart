import 'package:equatable/equatable.dart';
import '../../../domain/entities/portfolio_stock.dart';

abstract class PortfolioState extends Equatable {
  const PortfolioState();

  @override
  List<Object?> get props => [];
}

class PortfolioInitial extends PortfolioState {}

class PortfolioLoading extends PortfolioState {}

class PortfolioLoaded extends PortfolioState {
  final List<PortfolioStock> portfolio;
  final double greenScore;

  const PortfolioLoaded({
    required this.portfolio,
    required this.greenScore,
  });

  @override
  List<Object?> get props => [portfolio, greenScore];
}

class PortfolioError extends PortfolioState {
  final String message;

  const PortfolioError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StockAddedSuccess extends PortfolioState {
  final String symbol;

  const StockAddedSuccess({required this.symbol});

  @override
  List<Object?> get props => [symbol];
}
