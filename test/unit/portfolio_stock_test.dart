import 'package:flutter_test/flutter_test.dart';
import 'package:green_stocks/features/portfolio/domain/entities/esg_data.dart';
import 'package:green_stocks/features/portfolio/domain/entities/portfolio_stock.dart';
import 'package:green_stocks/features/portfolio/domain/entities/stock.dart';

void main() {
  const stock = Stock(
    symbol: 'TSLA',
    name: 'Tesla Inc.',
    price: 200.0,
    changePercent: 5.0,
    change: 10.0,
    volume: 50000,
    previousClose: 190.0,
  );

  const esgData = EsgData(
    symbol: 'TSLA',
    esgScore: 75.0,
    environmentScore: 80.0,
    socialScore: 70.0,
    governanceScore: 75.0,
    co2Emissions: 25.0,
    sustainabilityRating: SustainabilityRating.excellent,
  );

  group('PortfolioStock computed properties', () {
    const holding = PortfolioStock(
      stock: stock,
      esgData: esgData,
      quantity: 10.0,
      purchasePrice: 150.0,
    );

    test('currentValue calculates stock.price * quantity', () {
      expect(holding.currentValue, 2000.0);
    });

    test('costBasis calculates purchasePrice * quantity', () {
      expect(holding.costBasis, 1500.0);
    });

    test('pnl calculates currentValue - costBasis', () {
      expect(holding.pnl, 500.0);
    });

    test('pnlPercent calculates profit percentage correctly', () {
      expect(holding.pnlPercent, closeTo(33.33, 0.01));
    });

    test('pnlPercent returns 0 when costBasis is 0', () {
      const freeHolding = PortfolioStock(
        stock: stock,
        esgData: esgData,
        quantity: 10.0,
        purchasePrice: 0.0,
      );
      expect(freeHolding.pnlPercent, 0.0);
    });

    test('weightedCo2 returns co2Emissions from esgData', () {
      expect(holding.weightedCo2, 25.0);
    });

    test('copyWith correctly overrides specified fields', () {
      final updated = holding.copyWith(quantity: 20.0, purchasePrice: 160.0);
      expect(updated.quantity, 20.0);
      expect(updated.purchasePrice, 160.0);
      expect(updated.stock, stock);
      expect(updated.esgData, esgData);
    });
  });

  group('Stock computed properties', () {
    test('isGain returns true when changePercent >= 0', () {
      expect(stock.isGain, isTrue);
    });

    test('isGain returns false when changePercent < 0', () {
      const downStock = Stock(
        symbol: 'DOWN',
        name: 'Down Inc.',
        price: 50.0,
        changePercent: -2.5,
        change: -1.25,
        volume: 1000,
        previousClose: 51.25,
      );
      expect(downStock.isGain, isFalse);
    });
  });

  group('EsgData entity', () {
    test('ratingFromScore maps score thresholds properly', () {
      expect(EsgData.ratingFromScore(75), SustainabilityRating.excellent);
      expect(EsgData.ratingFromScore(60), SustainabilityRating.good);
      expect(EsgData.ratingFromScore(45), SustainabilityRating.fair);
      expect(EsgData.ratingFromScore(30), SustainabilityRating.poor);
      expect(EsgData.ratingFromScore(10), SustainabilityRating.veryPoor);
    });

    test('SustainabilityRatingX extension returns user-friendly label', () {
      expect(SustainabilityRating.excellent.label, 'Excellent');
      expect(SustainabilityRating.good.label, 'Good');
      expect(SustainabilityRating.fair.label, 'Fair');
      expect(SustainabilityRating.poor.label, 'Poor');
      expect(SustainabilityRating.veryPoor.label, 'Very Poor');
    });
  });
}
