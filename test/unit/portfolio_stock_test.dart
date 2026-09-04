import 'package:flutter_test/flutter_test.dart';
import 'package:green_stocks/features/portfolio/domain/entities/esg_data.dart';
import 'package:green_stocks/features/portfolio/domain/entities/portfolio_stock.dart';
import 'package:green_stocks/features/portfolio/domain/entities/stock.dart';

void main() {
  const stock = Stock(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    price: 150.0,
    change: 5.0,
    changePercent: 3.45,
    volume: 50000,
    previousClose: 145.0,
  );

  const esgData = EsgData(
    symbol: 'AAPL',
    esgScore: 75,
    environmentScore: 70,
    socialScore: 80,
    governanceScore: 75,
    co2Emissions: 45.0,
    sustainabilityRating: SustainabilityRating.excellent,
  );

  late PortfolioStock holding;

  setUp(() {
    holding = const PortfolioStock(
      stock: stock,
      esgData: esgData,
      quantity: 10,
      purchasePrice: 120.0,
    );
  });

  group('PortfolioStock computed properties', () {
    test('currentValue = price * quantity', () {
      expect(holding.currentValue, 150.0 * 10);
    });

    test('costBasis = purchasePrice * quantity', () {
      expect(holding.costBasis, 120.0 * 10);
    });

    test('pnl = currentValue - costBasis', () {
      final expectedPnl = (150.0 * 10) - (120.0 * 10);
      expect(holding.pnl, expectedPnl);
    });

    test('pnlPercent = (pnl / costBasis) * 100', () {
      final expectedPercent =
          ((150.0 * 10 - 120.0 * 10) / (120.0 * 10)) * 100;
      expect(holding.pnlPercent, closeTo(expectedPercent, 0.01));
    });

    test('pnlPercent returns 0 when costBasis is zero', () {
      final zeroHolding = const PortfolioStock(
        stock: stock,
        esgData: esgData,
        quantity: 0,
        purchasePrice: 0,
      );
      expect(zeroHolding.pnlPercent, 0);
    });

    test('weightedCo2 returns esgData.co2Emissions', () {
      expect(holding.weightedCo2, 45.0);
    });
  });

  group('PortfolioStock.copyWith', () {
    test('returns identical copy when no parameters given', () {
      final copy = holding.copyWith();
      expect(copy.stock.symbol, holding.stock.symbol);
      expect(copy.esgData.esgScore, holding.esgData.esgScore);
      expect(copy.quantity, holding.quantity);
      expect(copy.purchasePrice, holding.purchasePrice);
    });

    test('overrides quantity when provided', () {
      final copy = holding.copyWith(quantity: 20);
      expect(copy.quantity, 20);
      expect(copy.stock.symbol, 'AAPL'); // unchanged
    });

    test('overrides purchasePrice when provided', () {
      final copy = holding.copyWith(purchasePrice: 200);
      expect(copy.purchasePrice, 200);
      expect(copy.quantity, 10); // unchanged
    });

    test('overrides stock when provided', () {
      const newStock = Stock(
        symbol: 'MSFT',
        name: 'Microsoft',
        price: 300,
        change: 10,
        changePercent: 3.4,
        volume: 1000,
        previousClose: 290,
      );
      final copy = holding.copyWith(stock: newStock);
      expect(copy.stock.symbol, 'MSFT');
      expect(copy.esgData.symbol, 'AAPL'); // unchanged
    });
  });

  group('Stock.isGain', () {
    test('returns true when changePercent >= 0', () {
      expect(stock.isGain, true);
    });

    test('returns false when changePercent < 0', () {
      const losingStock = Stock(
        symbol: 'X',
        name: 'X Corp',
        price: 10,
        change: -2,
        changePercent: -5.0,
        volume: 100,
        previousClose: 12,
      );
      expect(losingStock.isGain, false);
    });
  });

  group('EsgData.ratingFromScore', () {
    test('returns excellent for score >= 70', () {
      expect(EsgData.ratingFromScore(70), SustainabilityRating.excellent);
      expect(EsgData.ratingFromScore(100), SustainabilityRating.excellent);
    });

    test('returns good for score >= 55 and < 70', () {
      expect(EsgData.ratingFromScore(55), SustainabilityRating.good);
      expect(EsgData.ratingFromScore(69), SustainabilityRating.good);
    });

    test('returns fair for score >= 40 and < 55', () {
      expect(EsgData.ratingFromScore(40), SustainabilityRating.fair);
      expect(EsgData.ratingFromScore(54), SustainabilityRating.fair);
    });

    test('returns poor for score >= 25 and < 40', () {
      expect(EsgData.ratingFromScore(25), SustainabilityRating.poor);
      expect(EsgData.ratingFromScore(39), SustainabilityRating.poor);
    });

    test('returns veryPoor for score < 25', () {
      expect(EsgData.ratingFromScore(24), SustainabilityRating.veryPoor);
      expect(EsgData.ratingFromScore(0), SustainabilityRating.veryPoor);
    });
  });

  group('SustainabilityRating labels', () {
    test('each rating returns correct label', () {
      expect(SustainabilityRating.excellent.label, 'Excellent');
      expect(SustainabilityRating.good.label, 'Good');
      expect(SustainabilityRating.fair.label, 'Fair');
      expect(SustainabilityRating.poor.label, 'Poor');
      expect(SustainabilityRating.veryPoor.label, 'Very Poor');
    });
  });
}
