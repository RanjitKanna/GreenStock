class Stock {
  const Stock({
    required this.symbol,
    required this.name,
    required this.price,
    required this.changePercent,
    required this.change,
    required this.volume,
    required this.previousClose,
  });

  final String symbol;
  final String name;
  final double price;
  final double changePercent;
  final double change;
  final double volume;
  final double previousClose;

  bool get isGain => changePercent >= 0;
}
