import 'stock.dart';
import 'esg_data.dart';

class PortfolioStock {
  const PortfolioStock({
    required this.stock,
    required this.esgData,
    required this.quantity,
    required this.purchasePrice,
  });

  final Stock stock;
  final EsgData esgData;
  final double quantity;
  final double purchasePrice;

  double get currentValue => stock.price * quantity;
  double get costBasis => purchasePrice * quantity;
  double get pnl => currentValue - costBasis;
  double get pnlPercent => costBasis == 0 ? 0 : (pnl / costBasis) * 100;
  double get weightedCo2 => esgData.co2Emissions;

  PortfolioStock copyWith({
    Stock? stock,
    EsgData? esgData,
    double? quantity,
    double? purchasePrice,
  }) {
    return PortfolioStock(
      stock: stock ?? this.stock,
      esgData: esgData ?? this.esgData,
      quantity: quantity ?? this.quantity,
      purchasePrice: purchasePrice ?? this.purchasePrice,
    );
  }
}
