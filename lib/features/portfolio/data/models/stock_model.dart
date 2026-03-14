import '../../domain/entities/stock.dart';

class StockModel extends Stock {
  const StockModel({
    required super.symbol,
    required super.name,
    required super.price,
    required super.changePercent,
    required super.change,
    required super.volume,
    required super.previousClose,
  });

  factory StockModel.fromAlphaVantage(
      Map<String, dynamic> json, String symbol) {
    final quote = json['Global Quote'] as Map<String, dynamic>? ?? {};
    return StockModel(
      symbol: (quote['01. symbol'] as String? ?? symbol).trim(),
      name: symbol,
      price: double.tryParse(quote['05. price'] as String? ?? '0') ?? 0,
      changePercent: double.tryParse(
            ((quote['10. change percent'] as String? ?? '0%')
                .replaceAll('%', '')),
          ) ??
          0,
      change: double.tryParse(quote['09. change'] as String? ?? '0') ?? 0,
      volume: double.tryParse(quote['06. volume'] as String? ?? '0') ?? 0,
      previousClose:
          double.tryParse(quote['08. previous close'] as String? ?? '0') ?? 0,
    );
  }

  factory StockModel.fromSearch(Map<String, dynamic> json) {
    return StockModel(
      symbol: json['1. symbol'] as String? ?? '',
      name: json['2. name'] as String? ?? '',
      price: 0,
      changePercent: 0,
      change: 0,
      volume: 0,
      previousClose: 0,
    );
  }

  factory StockModel.demo(String symbol) {
    final demos = _demoData[symbol.toUpperCase()];
    if (demos != null) return demos;
    return StockModel(
      symbol: symbol,
      name: symbol,
      price: 100.0,
      changePercent: 0.5,
      change: 0.5,
      volume: 1000000,
      previousClose: 99.5,
    );
  }

  static List<StockModel> get allKnownSymbols => _demoData.values.toList();

  static final Map<String, StockModel> _demoData = {
    'AAPL': const StockModel(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        price: 172.62,
        changePercent: 1.24,
        change: 2.11,
        volume: 58234120,
        previousClose: 170.51),
    'TSLA': const StockModel(
        symbol: 'TSLA',
        name: 'Tesla Inc.',
        price: 248.50,
        changePercent: -2.10,
        change: -5.34,
        volume: 102345678,
        previousClose: 253.84),
    'MSFT': const StockModel(
        symbol: 'MSFT',
        name: 'Microsoft Corp.',
        price: 415.32,
        changePercent: 0.87,
        change: 3.58,
        volume: 21345600,
        previousClose: 411.74),
    'GOOGL': const StockModel(
        symbol: 'GOOGL',
        name: 'Alphabet Inc.',
        price: 175.84,
        changePercent: 0.43,
        change: 0.75,
        volume: 18923400,
        previousClose: 175.09),
    'AMZN': const StockModel(
        symbol: 'AMZN',
        name: 'Amazon.com Inc.',
        price: 195.23,
        changePercent: 1.65,
        change: 3.17,
        volume: 41234500,
        previousClose: 192.06),
    'NVDA': const StockModel(
        symbol: 'NVDA',
        name: 'NVIDIA Corp.',
        price: 875.35,
        changePercent: 3.21,
        change: 27.21,
        volume: 49876543,
        previousClose: 848.14),
    'META': const StockModel(
        symbol: 'META',
        name: 'Meta Platforms',
        price: 525.00,
        changePercent: 1.10,
        change: 5.72,
        volume: 15678900,
        previousClose: 519.28),
    'BRK.B': const StockModel(
        symbol: 'BRK.B',
        name: 'Berkshire Hathaway',
        price: 398.12,
        changePercent: 0.22,
        change: 0.88,
        volume: 3456700,
        previousClose: 397.24),
    'JPM': const StockModel(
        symbol: 'JPM',
        name: 'JPMorgan Chase',
        price: 202.45,
        changePercent: 0.55,
        change: 1.11,
        volume: 9876543,
        previousClose: 201.34),
    'V': const StockModel(
        symbol: 'V',
        name: 'Visa Inc.',
        price: 279.80,
        changePercent: 0.31,
        change: 0.87,
        volume: 6789012,
        previousClose: 278.93),
    'JNJ': const StockModel(
        symbol: 'JNJ',
        name: 'Johnson & Johnson',
        price: 152.30,
        changePercent: -0.42,
        change: -0.64,
        volume: 7654321,
        previousClose: 152.94),
    'XOM': const StockModel(
        symbol: 'XOM',
        name: 'Exxon Mobil Corp.',
        price: 118.75,
        changePercent: -0.85,
        change: -1.02,
        volume: 18234500,
        previousClose: 119.77),
    'CVX': const StockModel(
        symbol: 'CVX',
        name: 'Chevron Corp.',
        price: 155.20,
        changePercent: -0.62,
        change: -0.97,
        volume: 11234500,
        previousClose: 156.17),
    'NEE': const StockModel(
        symbol: 'NEE',
        name: 'NextEra Energy',
        price: 63.40,
        changePercent: 0.95,
        change: 0.60,
        volume: 8765432,
        previousClose: 62.80),
    'ENPH': const StockModel(
        symbol: 'ENPH',
        name: 'Enphase Energy',
        price: 122.50,
        changePercent: 2.30,
        change: 2.76,
        volume: 5432100,
        previousClose: 119.74),
  };
}
