import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/entities/portfolio_stock.dart';
import '../../../domain/entities/esg_data.dart';

class StockDetailScreen extends StatelessWidget {
  const StockDetailScreen({super.key, required this.holding});
  final PortfolioStock holding;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final h = holding;
    final esg = h.esgData;
    final isGain = h.pnl >= 0;
    final scoreColor = esg.esgScore >= 70
        ? colors.greenScore
        : esg.esgScore >= 40
            ? colors.yellowScore
            : colors.redScore;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      scoreColor.withValues(alpha: 0.25),
                      scoreColor.withValues(alpha: 0.05),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(50, 12, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: [
                                  scoreColor.withValues(alpha: 0.3),
                                  scoreColor.withValues(alpha: 0.1),
                                ]),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                    color: scoreColor.withValues(alpha: 0.4)),
                              ),
                              child: Center(
                                child: Text(
                                  h.stock.symbol.isNotEmpty
                                      ? h.stock.symbol[0]
                                      : '?',
                                  style: TextStyle(
                                    color: scoreColor,
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(h.stock.symbol,
                                      style: theme.textTheme.displayMedium
                                          ?.copyWith(fontSize: 22)),
                                  Text(h.stock.name,
                                      style: theme.textTheme.bodyLarge,
                                      overflow: TextOverflow.ellipsis),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(Formatters.currency(h.stock.price),
                                    style: theme.textTheme.displayMedium
                                        ?.copyWith(fontSize: 20)),
                                Row(
                                  children: [
                                    Icon(
                                      isGain
                                          ? Icons.arrow_upward_rounded
                                          : Icons.arrow_downward_rounded,
                                      size: 14,
                                      color: isGain
                                          ? colors.gainColor
                                          : colors.lossColor,
                                    ),
                                    Text(
                                      Formatters.percent(h.stock.changePercent),
                                      style: TextStyle(
                                        color: isGain
                                            ? colors.gainColor
                                            : colors.lossColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _SectionTitle('Position', delay: 0)
                      .animate()
                      .fadeIn(delay: 100.ms),
                  const SizedBox(height: 10),
                  _PositionCard(holding: h, colors: colors)
                      .animate()
                      .fadeIn(delay: 150.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),
                  _SectionTitle('ESG Breakdown', delay: 0)
                      .animate()
                      .fadeIn(delay: 250.ms),
                  const SizedBox(height: 10),
                  _EsgBreakdownCard(
                          esg: esg, colors: colors, scoreColor: scoreColor)
                      .animate()
                      .fadeIn(delay: 300.ms, duration: 400.ms)
                      .slideY(begin: 0.2, end: 0),
                  const SizedBox(height: 20),
                  _SectionTitle('Carbon Profile', delay: 0)
                      .animate()
                      .fadeIn(delay: 400.ms),
                  const SizedBox(height: 10),
                  _CarbonRadarCard(esg: esg, colors: colors)
                      .animate()
                      .fadeIn(delay: 450.ms, duration: 400.ms)
                      .scaleXY(begin: 0.95, end: 1, curve: Curves.easeOut),
                  const SizedBox(height: 20),
                  if (esg.ecoAlternative != null) ...[
                    _EcoAlternativeBanner(
                      symbol: esg.ecoAlternative!,
                      colors: colors,
                    )
                        .animate()
                        .fadeIn(delay: 550.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0),
                    const SizedBox(height: 20),
                  ],
                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PositionCard extends StatelessWidget {
  const _PositionCard({required this.holding, required this.colors});
  final PortfolioStock holding;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final h = holding;
    final isGain = h.pnl >= 0;
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailTile(
                    label: 'Shares',
                    value: h.quantity.toStringAsFixed(0),
                    color: theme.colorScheme.onSurface),
                _DetailTile(
                    label: 'Avg Buy Price',
                    value: Formatters.currency(h.purchasePrice),
                    color: theme.colorScheme.onSurface),
                _DetailTile(
                    label: 'Market Value',
                    value: Formatters.currency(h.currentValue),
                    color: colors.gainColor),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _DetailTile(
                    label: 'Cost Basis',
                    value: Formatters.currency(h.costBasis),
                    color: theme.colorScheme.onSurface),
                _DetailTile(
                    label: 'P&L',
                    value: Formatters.currency(h.pnl),
                    color: isGain ? colors.gainColor : colors.lossColor),
                _DetailTile(
                    label: 'P&L%',
                    value: Formatters.percent(h.pnlPercent),
                    color: isGain ? colors.gainColor : colors.lossColor),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailTile extends StatelessWidget {
  const _DetailTile(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
        const SizedBox(height: 2),
        Text(value,
            style: Theme.of(context)
                .textTheme
                .titleMedium
                ?.copyWith(color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EsgBreakdownCard extends StatelessWidget {
  const _EsgBreakdownCard({
    required this.esg,
    required this.colors,
    required this.scoreColor,
  });
  final EsgData esg;
  final AppColors colors;
  final Color scoreColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Overall ESG Score',
                        style: theme.textTheme.bodyMedium),
                    Text(
                      esg.esgScore.toStringAsFixed(1),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: scoreColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(10),
                    border:
                        Border.all(color: scoreColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    esg.sustainabilityRating.label,
                    style: TextStyle(
                      color: scoreColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _ScoreBar(
                label: '🌿 Environmental',
                score: esg.environmentScore,
                colors: colors),
            const SizedBox(height: 8),
            _ScoreBar(
                label: '🤝 Social', score: esg.socialScore, colors: colors),
            const SizedBox(height: 8),
            _ScoreBar(
                label: '⚖️ Governance',
                score: esg.governanceScore,
                colors: colors),
            const Divider(height: 20),
            Row(
              children: [
                Icon(Icons.cloud_outlined, size: 16, color: colors.subtleText),
                const SizedBox(width: 6),
                Text('Annual CO₂ Emissions: ',
                    style: theme.textTheme.bodyLarge),
                Text(
                  Formatters.co2(esg.co2Emissions),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: esg.co2Emissions > 100
                        ? colors.redScore
                        : esg.co2Emissions > 30
                            ? colors.yellowScore
                            : colors.greenScore,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBar extends StatefulWidget {
  const _ScoreBar(
      {required this.label, required this.score, required this.colors});
  final String label;
  final double score;
  final AppColors colors;

  @override
  State<_ScoreBar> createState() => _ScoreBarState();
}

class _ScoreBarState extends State<_ScoreBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _anim = Tween<double>(begin: 0, end: widget.score / 100)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Color get _barColor {
    if (widget.score >= 70) return widget.colors.greenScore;
    if (widget.score >= 40) return widget.colors.yellowScore;
    return widget.colors.redScore;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label, style: theme.textTheme.bodyLarge),
            Text(
              widget.score.toStringAsFixed(0),
              style: TextStyle(
                  color: _barColor, fontWeight: FontWeight.w700, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        AnimatedBuilder(
          animation: _anim,
          builder: (ctx, _) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _anim.value,
                backgroundColor: _barColor.withValues(alpha: 0.12),
                valueColor: AlwaysStoppedAnimation(_barColor),
                minHeight: 6,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _CarbonRadarCard extends StatelessWidget {
  const _CarbonRadarCard({required this.esg, required this.colors});
  final EsgData esg;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ESG Pillars vs Industry Avg',
                style: theme.textTheme.bodyMedium),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: RadarChart(
                RadarChartData(
                  dataSets: [
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: esg.environmentScore),
                        RadarEntry(value: esg.socialScore),
                        RadarEntry(value: esg.governanceScore),
                        RadarEntry(value: esg.esgScore),
                      ],
                      fillColor: colors.greenScore.withValues(alpha: 0.2),
                      borderColor: colors.greenScore,
                      borderWidth: 2,
                      entryRadius: 4,
                    ),
                    RadarDataSet(
                      dataEntries: [
                        RadarEntry(value: 52), // industry avg
                        RadarEntry(value: 50),
                        RadarEntry(value: 55),
                        RadarEntry(value: 52),
                      ],
                      fillColor: colors.subtleText.withValues(alpha: 0.08),
                      borderColor: colors.subtleText.withValues(alpha: 0.5),
                      borderWidth: 1.5,
                      entryRadius: 3,
                    ),
                  ],
                  radarBackgroundColor: Colors.transparent,
                  radarBorderData: BorderSide(color: colors.borderColor),
                  gridBorderData:
                      BorderSide(color: colors.borderColor, width: 0.8),
                  radarShape: RadarShape.polygon,
                  tickCount: 4,
                  tickBorderData: BorderSide(color: colors.borderColor),
                  getTitle: (index, _) => RadarChartTitle(
                    text: ['Environ.', 'Social', 'Govern.', 'Overall'][index],
                    positionPercentageOffset: 0.1,
                  ),
                  titleTextStyle: TextStyle(
                      color: colors.subtleText,
                      fontSize: 11,
                      fontWeight: FontWeight.w500),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _LegendDot(color: colors.greenScore, label: esg.symbol),
                const SizedBox(width: 16),
                _LegendDot(
                    color: colors.subtleText.withValues(alpha: 0.6),
                    label: 'Industry Avg'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label,
            style:
                Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 11)),
      ],
    );
  }
}

class _EcoAlternativeBanner extends StatelessWidget {
  const _EcoAlternativeBanner({required this.symbol, required this.colors});
  final String symbol;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colors.greenScore.withValues(alpha: 0.15),
            colors.greenScore.withValues(alpha: 0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.greenScore.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.eco_rounded, color: colors.greenScore, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('🌱 Eco-Friendly Alternative',
                    style: theme.textTheme.titleMedium
                        ?.copyWith(color: colors.greenScore)),
                const SizedBox(height: 4),
                Text(
                  'Consider $symbol for a greener investment with higher ESG scores and lower CO₂ emissions.',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, {required this.delay});
  final String title;
  final int delay;

  @override
  Widget build(BuildContext context) {
    return Text(title, style: Theme.of(context).textTheme.titleMedium);
  }
}
