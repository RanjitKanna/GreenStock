enum SustainabilityRating { excellent, good, fair, poor, veryPoor }

extension SustainabilityRatingX on SustainabilityRating {
  String get label {
    switch (this) {
      case SustainabilityRating.excellent:
        return 'Excellent';
      case SustainabilityRating.good:
        return 'Good';
      case SustainabilityRating.fair:
        return 'Fair';
      case SustainabilityRating.poor:
        return 'Poor';
      case SustainabilityRating.veryPoor:
        return 'Very Poor';
    }
  }
}

class EsgData {
  const EsgData({
    required this.symbol,
    required this.esgScore,
    required this.environmentScore,
    required this.socialScore,
    required this.governanceScore,
    required this.co2Emissions,
    required this.sustainabilityRating,
    this.ecoAlternative,
  });

  final String symbol;
  final double esgScore;
  final double environmentScore;
  final double socialScore;
  final double governanceScore;
  final double co2Emissions;
  final SustainabilityRating sustainabilityRating;
  final String? ecoAlternative;

  static SustainabilityRating ratingFromScore(double score) {
    if (score >= 70) return SustainabilityRating.excellent;
    if (score >= 55) return SustainabilityRating.good;
    if (score >= 40) return SustainabilityRating.fair;
    if (score >= 25) return SustainabilityRating.poor;
    return SustainabilityRating.veryPoor;
  }
}
