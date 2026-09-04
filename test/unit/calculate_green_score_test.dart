import 'package:flutter_test/flutter_test.dart';
import 'package:green_stocks/features/portfolio/domain/entities/esg_data.dart';
import 'package:green_stocks/features/portfolio/domain/entities/portfolio_stock.dart';
import 'package:green_stocks/features/portfolio/domain/entities/stock.dart';
import 'package:green_stocks/features/portfolio/domain/usecases/calculate_green_score.dart';

void main() {
  late CalculateGreenScore calculateGreenScore;

  setUp(() {
    calculateGreenScore = const CalculateGreenScore();
  });

  PortfolioStock _makeHolding({
    String symbol = 'TEST',
    double price = 100.0,
    double quantity = 10,
    double purchasePrice = 90.0,
    double co2Emissions = 50.0,
    double esgScore = 70,
  }) {
    return PortfolioStock(
      stock: Stock(
        symbol: symbol,
        name: '$symbol Inc.',
        price: price,
        change: price - 90,
        changePercent: ((price - 90) / 90) * 100,
        volume: 1000,
        previousClose: 90,
      ),
      esgData: EsgData(
        symbol: symbol,
        esgScore: esgScore,
        environmentScore: 60,
        socialScore: 70,
        governanceScore: 80,
        co2Emissions: co2Emissions,
        sustainabilityRating: EsgData.ratingFromScore(esgScore),
      ),
      quantity: quantity,
      purchasePrice: purchasePrice,
    );
  }

  group('CalculateGreenScore', () {
    test('returns 100 for empty portfolio', () {
      expect(calculateGreenScore([]), 100.0);
    });

    test('returns 100 when all stock prices are zero (zero total value)', () {
      final portfolio = [
        _makeHolding(price: 0, quantity: 5, co2Emissions: 200),
      ];
      expect(calculateGreenScore(portfolio), 100.0);
    });

    test('returns high score for single low-CO₂ stock', () {
      // co2 = 10, maxRef = 500 → penalty = 10/500 * 100 = 2.0
      final portfolio = [_makeHolding(co2Emissions: 10)];
      final score = calculateGreenScore(portfolio);
      expect(score, closeTo(98.0, 0.01));
    });

    test('returns low score for single very-high-CO₂ stock', () {
      // co2 = 500 (== maxRef) → penalty = 500/500 * 100 = 100 → score = 0
      final portfolio = [_makeHolding(co2Emissions: 500)];
      final score = calculateGreenScore(portfolio);
      expect(score, closeTo(0.0, 0.01));
    });

    test('clamps CO₂ above max reference to 1.0', () {
      // co2 = 800 → clamped to 1.0 → penalty = 100 → score = 0
      final portfolio = [_makeHolding(co2Emissions: 800)];
      final score = calculateGreenScore(portfolio);
      expect(score, 0.0);
    });

    test('correctly calculates weighted score for mixed portfolio', () {
      // Stock A: value = 100*10 = 1000, co2 = 50 → penalty = (1000/1500) * (50/500) * 100
      // Stock B: value = 50*10  =  500, co2 = 250 → penalty = (500/1500) * (250/500) * 100
      final portfolio = [
        _makeHolding(symbol: 'A', price: 100, quantity: 10, co2Emissions: 50),
        _makeHolding(symbol: 'B', price: 50, quantity: 10, co2Emissions: 250),
      ];
      final score = calculateGreenScore(portfolio);

      final weightA = 1000 / 1500;
      final weightB = 500 / 1500;
      final penaltyA = weightA * (50 / 500) * 100;
      final penaltyB = weightB * (250 / 500) * 100;
      final expected = 100 - (penaltyA + penaltyB);

      expect(score, closeTo(expected, 0.01));
    });

    test('result is always clamped between 0 and 100', () {
      final lowCo2 = [_makeHolding(co2Emissions: 0)];
      final highCo2 = [_makeHolding(co2Emissions: 1000)];

      expect(calculateGreenScore(lowCo2), 100.0);
      expect(calculateGreenScore(highCo2), 0.0);
    });
  });

  group('CalculateGreenScore.band', () {
    test('returns Excellent for score >= 70', () {
      expect(calculateGreenScore.band(70), 'Excellent');
      expect(calculateGreenScore.band(100), 'Excellent');
    });

    test('returns Fair for score >= 40 and < 70', () {
      expect(calculateGreenScore.band(40), 'Fair');
      expect(calculateGreenScore.band(69.9), 'Fair');
    });

    test('returns Poor for score < 40', () {
      expect(calculateGreenScore.band(39.9), 'Poor');
      expect(calculateGreenScore.band(0), 'Poor');
    });
  });
}
