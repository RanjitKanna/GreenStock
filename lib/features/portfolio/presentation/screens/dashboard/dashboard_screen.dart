import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../domain/entities/portfolio_stock.dart';
import '../../../domain/entities/esg_data.dart';
import '../../../domain/entities/stock.dart';
import '../../blocs/portfolio/portfolio_bloc.dart';
import '../../blocs/portfolio/portfolio_event.dart';
import '../../blocs/portfolio/portfolio_state.dart';
import '../../../../../core/theme/theme_cubit.dart';
import '../../../../../core/utils/currency_cubit.dart';
import '../../../../../core/widgets/currency_toggle.dart';
import '../../../../../core/widgets/tappable_scale.dart';
import '../add_stock/add_stock_sheet.dart';
import '../stock_detail/stock_detail_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    final dummyPortfolio = List.generate(
      3,
      (i) => PortfolioStock(
        stock: Stock(
          symbol: 'SKELETON',
          name: 'Skeleton Company Name',
          price: 150.0,
          change: 2.5,
          changePercent: 1.5,
          volume: 1000,
          previousClose: 148.5,
        ),
        esgData: EsgData(
          symbol: 'SKELETON',
          esgScore: 80,
          environmentScore: 70,
          socialScore: 85,
          governanceScore: 75,
          co2Emissions: 45.0,
          sustainabilityRating: SustainabilityRating.excellent,
        ),
        quantity: 10,
        purchasePrice: 140.0,
      ),
    );

    return Scaffold(
      body: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return BlocBuilder<PortfolioBloc, PortfolioState>(
            builder: (context, state) {
              return RefreshIndicator(
                onRefresh: () async {
                  context.read<PortfolioBloc>().add(RefreshPortfolio());
                },
                child: CustomScrollView(
                  slivers: [
                    _buildAppBar(context, isDark, theme),
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          if (state is PortfolioLoading ||
                              state is PortfolioInitial) {
                            return Skeletonizer(
                              enabled: true,
                              child: _buildContent(
                                context,
                                dummyPortfolio,
                                80.0,
                                colors,
                                theme,
                                isSkeleton: false,
                              ),
                            );
                          } else if (state is PortfolioError) {
                            return _buildError(context, state.message);
                          } else if (state is PortfolioLoaded) {
                            return _buildContent(
                              context,
                              state.portfolio,
                              state.greenScore,
                              colors,
                              theme,
                            );
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddStock(context),
        backgroundColor: const Color(0xFF10B981),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Stock',
            style: TextStyle(fontWeight: FontWeight.w600)),
      )
          .animate()
          .fadeIn(delay: 600.ms, duration: 400.ms)
          .slideY(begin: 1, end: 0, curve: Curves.easeOutBack),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isDark, ThemeData theme) {
    return SliverAppBar(
      expandedHeight: 80.0,
      collapsedHeight: 60.0,
      floating: true,
      pinned: true,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.2,
        titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
        title: Row(
          children: [
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: const DecorationImage(
                  image: AssetImage('assets/images/app_logo.png'),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text('Green Stock',
                style: theme.textTheme.titleLarge?.copyWith(fontSize: 18)),
            const Spacer(),
            BlocBuilder<CurrencyCubit, CurrencyState>(
              builder: (context, currencyState) {
                return CurrencyToggle(
                  currentType: currencyState.type,
                  onToggle: () =>
                      context.read<CurrencyCubit>().toggleCurrency(),
                );
              },
            ),
            IconButton(
              padding: const EdgeInsets.all(4),
              constraints: const BoxConstraints(),
              onPressed: () => context.read<ThemeCubit>().toggleTheme(),
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  size: 20,
                  isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                  key: ValueKey(isDark),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
      ),
      actions: [],
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<PortfolioStock> portfolio,
    double greenScore,
    AppColors colors,
    ThemeData theme, {
    bool isSkeleton = false,
  }) {
    final totalValue = portfolio.fold<double>(0, (s, p) => s + p.currentValue);
    final totalCo2 =
        portfolio.fold<double>(0, (s, p) => s + p.esgData.co2Emissions);
    final totalPnl = portfolio.fold<double>(0, (s, p) => s + p.pnl);

    return BlocBuilder<CurrencyCubit, CurrencyState>(
      builder: (context, currencyState) {
        return Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GreenScoreCard(greenScore: greenScore, colors: colors)
                  .animate(target: isSkeleton ? 0 : 1)
                  .fadeIn(duration: 500.ms)
                  .slideY(begin: -0.2, end: 0, curve: Curves.easeOut),
              const SizedBox(height: 16),
              _SummaryRow(
                totalValue: currencyState.convert(totalValue),
                totalCo2: totalCo2,
                totalPnl: currencyState.convert(totalPnl),
                colors: colors,
                currencySymbol: currencyState.symbol,
              )
                  .animate(target: isSkeleton ? 0 : 1)
                  .fadeIn(delay: 100.ms, duration: 500.ms)
                  .slideY(begin: 0.2, end: 0),
              if (portfolio.isNotEmpty) ...[
                const SizedBox(height: 20),
                const Skeleton.keep(
                  child: Text('CO₂ Breakdown',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ).animate(target: isSkeleton ? 0 : 1).fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
                _Co2Chart(portfolio: portfolio, colors: colors)
                    .animate(target: isSkeleton ? 0 : 1)
                    .fadeIn(delay: 300.ms, duration: 500.ms)
                    .scaleXY(begin: 0.95, end: 1, curve: Curves.easeOut),
                const SizedBox(height: 20),
                const Skeleton.keep(
                  child: Text('Your Holdings',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ).animate(target: isSkeleton ? 0 : 1).fadeIn(delay: 400.ms),
                const SizedBox(height: 12),
                ...portfolio.asMap().entries.map(
                      (e) => _HoldingCard(
                        holding: e.value,
                        colors: colors,
                        index: e.key,
                        onTap: () => _openDetail(context, e.value),
                        isSkeleton: isSkeleton,
                        currencyState: currencyState,
                      ),
                    ),
              ] else if (!isSkeleton)
                _EmptyState().animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 100),
            ],
          ),
        );
      },
    );
  }

  Widget _buildError(BuildContext context, Object e) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            const Icon(Icons.error_outline_rounded,
                color: Color(0xFFFF5252), size: 48),
            const SizedBox(height: 12),
            Text('Failed to load portfolio',
                style: Theme.of(context).textTheme.titleMedium),
            Text('$e', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }

  void _showAddStock(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AddStockSheet(),
    );
  }

  void _openDetail(BuildContext context, PortfolioStock holding) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => StockDetailScreen(holding: holding),
        transitionsBuilder: (ctx, anim, secondAnim, child) {
          return FadeTransition(
            opacity: anim,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.08),
                end: Offset.zero,
              ).animate(
                  CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }
}

class _GreenScoreCard extends StatelessWidget {
  const _GreenScoreCard({required this.greenScore, required this.colors});
  final double greenScore;
  final AppColors colors;

  Color get _gaugeColor {
    if (greenScore >= 70) return colors.greenScore;
    if (greenScore >= 40) return colors.yellowScore;
    return colors.redScore;
  }

  String get _band {
    if (greenScore >= 70) return 'Excellent';
    if (greenScore >= 40) return 'Fair';
    return 'Poor';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            _gaugeColor.withValues(alpha: 0.15),
            _gaugeColor.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: _gaugeColor.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          CircularPercentIndicator(
            radius: 54,
            lineWidth: 8,
            percent: (greenScore / 100).clamp(0.0, 1.0),
            animation: true,
            animationDuration: 1200,
            animateFromLastPercent: true,
            curve: Curves.easeOutCubic,
            progressColor: _gaugeColor,
            backgroundColor: _gaugeColor.withValues(alpha: 0.15),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  greenScore.toStringAsFixed(0),
                  style: theme.textTheme.displayMedium?.copyWith(
                    color: _gaugeColor,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Green Score', style: theme.textTheme.bodyMedium),
                const SizedBox(height: 4),
                Text(_band,
                    style: theme.textTheme.titleLarge?.copyWith(
                      color: _gaugeColor,
                      fontWeight: FontWeight.w700,
                    )),
                const SizedBox(height: 8),
                Text(
                  greenScore >= 70
                      ? 'Your portfolio has a low carbon footprint'
                      : greenScore >= 40
                          ? 'Consider greener alternatives'
                          : 'High emissions — action needed',
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

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.totalValue,
    required this.totalCo2,
    required this.totalPnl,
    required this.colors,
    required this.currencySymbol,
  });

  final double totalValue, totalCo2, totalPnl;
  final AppColors colors;
  final String currencySymbol;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Portfolio',
            value: Formatters.currency(totalValue, symbol: currencySymbol),
            color: colors.gainColor,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _MetricTile(
            icon: Icons.cloud_rounded,
            label: 'Total CO₂',
            value: Formatters.co2(totalCo2),
            color: totalCo2 > 100 ? colors.redScore : colors.yellowScore,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: _MetricTile(
            icon: Icons.trending_up_rounded,
            label: 'P&L',
            value: Formatters.currency(totalPnl, symbol: currencySymbol),
            color: totalPnl >= 0 ? colors.gainColor : colors.lossColor,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 110,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 8),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 2),
              FittedBox(
                alignment: Alignment.centerLeft,
                fit: BoxFit.scaleDown,
                child: Text(
                  value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Co2Chart extends StatelessWidget {
  const _Co2Chart({required this.portfolio, required this.colors});
  final List<PortfolioStock> portfolio;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final sorted = [
      ...portfolio
    ]..sort((a, b) => b.esgData.co2Emissions.compareTo(a.esgData.co2Emissions));
    final displayed = sorted.take(6).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
        child: SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: (displayed.first.esgData.co2Emissions * 1.3).ceilToDouble(),
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => colors.cardBg,
                  getTooltipItem: (group, _, rod, __) => BarTooltipItem(
                    '${displayed[group.x].stock.symbol}\n${Formatters.co2(rod.toY)}',
                    TextStyle(
                      color: colors.gainColor,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (_) => FlLine(
                  color: colors.borderColor,
                  strokeWidth: 1,
                  dashArray: [4, 4],
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles:
                    const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final i = value.toInt();
                      if (i < 0 || i >= displayed.length) {
                        return const SizedBox();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          displayed[i].stock.symbol,
                          style:
                              TextStyle(fontSize: 10, color: colors.subtleText),
                        ),
                      );
                    },
                  ),
                ),
              ),
              barGroups: displayed.asMap().entries.map((e) {
                final co2 = e.value.esgData.co2Emissions;
                final color = co2 > 200
                    ? colors.redScore
                    : co2 > 50
                        ? colors.yellowScore
                        : colors.greenScore;
                return BarChartGroupData(
                  x: e.key,
                  barRods: [
                    BarChartRodData(
                      toY: co2,
                      color: color,
                      width: 28,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(6)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: displayed.first.esgData.co2Emissions * 1.3,
                        color: color.withValues(alpha: 0.08),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
            swapAnimationDuration: const Duration(milliseconds: 800),
            swapAnimationCurve: Curves.easeOutCubic,
          ),
        ),
      ),
    );
  }
}

class _HoldingCard extends StatelessWidget {
  const _HoldingCard({
    required this.holding,
    required this.colors,
    required this.index,
    required this.onTap,
    this.isSkeleton = false,
    required this.currencyState,
  });

  final PortfolioStock holding;
  final AppColors colors;
  final int index;
  final VoidCallback onTap;
  final bool isSkeleton;
  final CurrencyState currencyState;

  @override
  Widget build(BuildContext context) {
    final h = holding;
    final theme = Theme.of(context);
    final isGain = h.pnl >= 0;
    final symbol = currencyState.symbol;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TappableScale(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                _SymbolBadge(symbol: h.stock.symbol, color: colors.gainColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(h.stock.symbol, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(h.stock.name,
                          style: theme.textTheme.bodyMedium,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _EsgChip(score: h.esgData.esgScore, colors: colors),
                          const SizedBox(width: 6),
                          Icon(Icons.cloud_outlined,
                              size: 12, color: colors.subtleText),
                          const SizedBox(width: 2),
                          Text(
                            Formatters.co2(h.esgData.co2Emissions),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                        Formatters.currency(
                            currencyState.convert(h.currentValue),
                            symbol: symbol),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        )),
                    const SizedBox(height: 2),
                    Text(
                      Formatters.currency(currencyState.convert(h.stock.price),
                          symbol: symbol),
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isGain
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          size: 12,
                          color: isGain ? colors.gainColor : colors.lossColor,
                        ),
                        Text(
                          Formatters.percent(h.pnlPercent),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: isGain ? colors.gainColor : colors.lossColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      )
          .animate(target: isSkeleton ? 0 : 1, delay: (index * 80).ms)
          .fadeIn(duration: 400.ms)
          .slideY(begin: 0.3, end: 0, curve: Curves.easeOut),
    );
  }
}

class _EsgChip extends StatelessWidget {
  const _EsgChip({required this.score, required this.colors});
  final double score;
  final AppColors colors;

  Color get _color {
    if (score >= 70) return colors.greenScore;
    if (score >= 40) return colors.yellowScore;
    return colors.redScore;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        'ESG ${score.toStringAsFixed(0)}',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: _color,
        ),
      ),
    ).animate().scale(
        begin: const Offset(0, 0),
        end: const Offset(1, 1),
        duration: 300.ms,
        curve: Curves.easeOutBack);
  }
}

class _SymbolBadge extends StatelessWidget {
  const _SymbolBadge({required this.symbol, required this.color});
  final String symbol;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final letter = symbol.isNotEmpty ? symbol[0] : '?';
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.3), color.withValues(alpha: 0.15)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Center(
        child: Text(
          letter,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.only(top: 20),
      child: Center(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.eco_rounded,
                  color: Color(0xFF10B981), size: 40),
            ),
            const SizedBox(height: 16),
            Text('No stocks yet', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to add your first\nstock and track its green impact',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
