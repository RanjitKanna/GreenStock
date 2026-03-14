import '../entities/portfolio_stock.dart';

class CalculateGreenScore {
  const CalculateGreenScore();

  static const double _maxCo2Reference = 500.0;

  double call(List<PortfolioStock> portfolio) {
    if (portfolio.isEmpty) return 100.0;

    final totalValue = portfolio.fold<double>(
      0.0,
      (sum, p) => sum + p.currentValue,
    );

    if (totalValue == 0) return 100.0;

    double weightedPenalty = 0.0;
    for (final holding in portfolio) {
      final weight = holding.currentValue / totalValue;
      final normalizedCo2 =
          (holding.esgData.co2Emissions / _maxCo2Reference).clamp(0.0, 1.0);
      weightedPenalty += weight * normalizedCo2 * 100;
    }

    return (100 - weightedPenalty).clamp(0.0, 100.0);
  }

  String band(double score) {
    if (score >= 70) return 'Excellent';
    if (score >= 40) return 'Fair';
    return 'Poor';
  }
}
