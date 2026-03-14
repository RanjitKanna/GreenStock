class PortfolioEntry {
  const PortfolioEntry({
    required this.symbol,
    required this.quantity,
    required this.purchasePrice,
  });

  final String symbol;
  final double quantity;
  final double purchasePrice;

  Map<String, dynamic> toJson() => {
        'symbol': symbol,
        'quantity': quantity,
        'purchasePrice': purchasePrice,
      };

  factory PortfolioEntry.fromJson(Map<String, dynamic> json) => PortfolioEntry(
        symbol: json['symbol'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        purchasePrice: (json['purchasePrice'] as num).toDouble(),
      );
}
