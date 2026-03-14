import 'package:equatable/equatable.dart';


abstract class PortfolioEvent extends Equatable {
  const PortfolioEvent();

  @override
  List<Object> get props => [];
}

class LoadPortfolio extends PortfolioEvent {}

class RefreshPortfolio extends PortfolioEvent {}

class AddStockEvent extends PortfolioEvent {
  final String symbol;
  final double quantity;
  final double price;

  const AddStockEvent({
    required this.symbol,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object> get props => [symbol, quantity, price];
}

class RemoveStockEvent extends PortfolioEvent {
  final String symbol;

  const RemoveStockEvent({required this.symbol});

  @override
  List<Object> get props => [symbol];
}
