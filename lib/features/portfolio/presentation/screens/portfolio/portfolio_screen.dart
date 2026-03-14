import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/tappable_scale.dart';
import '../../../domain/entities/portfolio_stock.dart';
import '../../../domain/entities/esg_data.dart';
import '../../../domain/entities/stock.dart';
import '../../blocs/portfolio/portfolio_bloc.dart';
import '../../blocs/portfolio/portfolio_event.dart';
import '../../blocs/portfolio/portfolio_state.dart';
import '../stock_detail/stock_detail_screen.dart';
import '../../../../../core/utils/currency_cubit.dart';

class PortfolioScreen extends StatelessWidget {
  const PortfolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);
    final dummyPortfolio = List.generate(
      3,
      (i) => PortfolioStock(
        stock: const Stock(
          symbol: 'SKELETON',
          name: 'Skeleton Company Name',
          price: 150.0,
          change: 2.5,
          changePercent: 1.5,
          volume: 1000,
          previousClose: 148.5,
        ),
        esgData: const EsgData(
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
      body: SafeArea(
        child: BlocBuilder<CurrencyCubit, CurrencyState>(
          builder: (context, currencyState) {
            return BlocBuilder<PortfolioBloc, PortfolioState>(
              builder: (context, state) {
                if (state is PortfolioLoading || state is PortfolioInitial) {
                  return Skeletonizer(
                    enabled: true,
                    child: _buildContent(
                      context,
                      dummyPortfolio,
                      80.0,
                      colors,
                      theme,
                      currencyState,
                      isSkeleton: true,
                    ),
                  );
                } else if (state is PortfolioError) {
                  return Center(child: Text('Error: ${state.message}'));
                } else if (state is PortfolioLoaded) {
                  if (state.portfolio.isEmpty) {
                    return _PortfolioEmpty()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: 0.2, end: 0);
                  }
                  return _buildContent(
                    context,
                    state.portfolio,
                    state.greenScore,
                    colors,
                    theme,
                    currencyState,
                  );
                }
                return const SizedBox.shrink();
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<PortfolioStock> portfolio,
    double greenScore,
    AppColors colors,
    ThemeData theme,
    CurrencyState currencyState, {
    bool isSkeleton = false,
  }) {
    final totalValue = portfolio.fold<double>(0, (s, p) => s + p.currentValue);
    final totalCo2 =
        portfolio.fold<double>(0, (s, p) => s + p.esgData.co2Emissions);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Skeleton.keep(
                  child: Text('My Portfolio',
                      style: theme.textTheme.displayMedium
                          ?.copyWith(fontSize: 26)),
                )
                    .animate(target: isSkeleton ? 0 : 1)
                    .fadeIn()
                    .slideY(begin: -0.2, end: 0),
                const SizedBox(height: 16),
                _PortfolioTopBanner(
                  totalValue: totalValue,
                  totalCo2: totalCo2,
                  greenScore: greenScore,
                  count: portfolio.length,
                  colors: colors,
                  currencyState: currencyState,
                )
                    .animate(target: isSkeleton ? 0 : 1)
                    .fadeIn(delay: 100.ms, duration: 500.ms)
                    .scaleXY(begin: 0.96, end: 1, curve: Curves.easeOut),
                const SizedBox(height: 20),
                Skeleton.keep(
                  child: Text('${portfolio.length} Holdings',
                      style: theme.textTheme.titleMedium),
                ).animate(target: isSkeleton ? 0 : 1).fadeIn(delay: 200.ms),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (ctx, i) => Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: _PortfolioRow(
                holding: portfolio[i],
                colors: colors,
                index: i,
                onTap: () => _openDetail(context, portfolio[i]),
                onRemove: () => context.read<PortfolioBloc>().add(
                      RemoveStockEvent(symbol: portfolio[i].stock.symbol),
                    ),
                currencyState: currencyState,
                isSkeleton: isSkeleton,
              ),
            ),
            childCount: portfolio.length,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 32)),
      ],
    );
  }

  void _openDetail(BuildContext context, PortfolioStock holding) {
    Navigator.of(context).push(
      PageRouteBuilder(
        pageBuilder: (ctx, anim, _) => StockDetailScreen(holding: holding),
        transitionsBuilder: (ctx, anim, _, child) {
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
      ),
    );
  }
}

class _PortfolioTopBanner extends StatelessWidget {
  const _PortfolioTopBanner({
    required this.totalValue,
    required this.totalCo2,
    required this.greenScore,
    required this.count,
    required this.colors,
    required this.currencyState,
  });
  final double totalValue, totalCo2, greenScore;
  final int count;
  final AppColors colors;
  final CurrencyState currencyState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scoreColor = greenScore >= 70
        ? colors.greenScore
        : greenScore >= 40
            ? colors.yellowScore
            : colors.redScore;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withValues(alpha: 0.2),
            const Color(0xFF10B981).withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border:
            Border.all(color: const Color(0xFF10B981).withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total Value', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text(
                      Formatters.currency(
                        currencyState.convert(totalValue),
                        symbol: currencyState.symbol,
                      ),
                      style: theme.textTheme.displayMedium?.copyWith(
                        color: colors.gainColor,
                        fontWeight: FontWeight.w800,
                      )),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('Green Score', style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 4),
                  Text('${greenScore.toStringAsFixed(0)}/100',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: scoreColor,
                        fontWeight: FontWeight.w700,
                      )),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatPill(
                  label: 'CO₂ Impact',
                  value: Formatters.co2(totalCo2),
                  icon: Icons.cloud_rounded,
                  color: totalCo2 > 100 ? colors.redScore : colors.yellowScore,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _StatPill(
                  label: 'Holdings',
                  value: '$count stocks',
                  icon: Icons.show_chart_rounded,
                  color: colors.gainColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: theme.textTheme.bodyMedium?.copyWith(fontSize: 11)),
                Text(value,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontSize: 13,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PortfolioRow extends StatelessWidget {
  const _PortfolioRow({
    required this.holding,
    required this.colors,
    required this.index,
    required this.onTap,
    required this.onRemove,
    required this.currencyState,
    this.isSkeleton = false,
  });
  final PortfolioStock holding;
  final AppColors colors;
  final int index;
  final VoidCallback onTap, onRemove;
  final CurrencyState currencyState;
  final bool isSkeleton;

  Color _scoreColor(double s) {
    if (s >= 70) return colors.greenScore;
    if (s >= 40) return colors.yellowScore;
    return colors.redScore;
  }

  @override
  Widget build(BuildContext context) {
    final h = holding;
    final theme = Theme.of(context);
    final isGain = h.pnl >= 0;
    final scoreColor = _scoreColor(h.esgData.esgScore);

    return Dismissible(
      key: ValueKey('portfolio_${h.stock.symbol}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: colors.redScore.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(Icons.delete_rounded, color: colors.redScore, size: 28),
      ),
      onDismissed: (_) => onRemove(),
      child: TappableScale(
        onTap: onTap,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          scoreColor.withValues(alpha: 0.25),
                          scoreColor.withValues(alpha: 0.08),
                        ]),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: scoreColor.withValues(alpha: 0.35)),
                      ),
                      child: Center(
                        child: Text(
                          h.stock.symbol.isNotEmpty ? h.stock.symbol[0] : '?',
                          style: TextStyle(
                            color: scoreColor,
                            fontWeight: FontWeight.w800,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(h.stock.symbol,
                              style: theme.textTheme.titleMedium),
                          Text(h.stock.name,
                              style: theme.textTheme.bodyMedium,
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                            Formatters.currency(
                              currencyState.convert(h.currentValue),
                              symbol: currencyState.symbol,
                            ),
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700)),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isGain
                                  ? Icons.arrow_upward_rounded
                                  : Icons.arrow_downward_rounded,
                              size: 12,
                              color:
                                  isGain ? colors.gainColor : colors.lossColor,
                            ),
                            Text(
                              '${Formatters.currency(
                                currencyState.convert(h.pnl),
                                symbol: currencyState.symbol,
                              )} (${Formatters.percent(h.pnlPercent)})',
                              style: TextStyle(
                                color: isGain
                                    ? colors.gainColor
                                    : colors.lossColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniStat(
                      label: 'Qty',
                      value: '${h.quantity.toStringAsFixed(0)} shares',
                      color: colors.subtleText,
                    ),
                    _MiniStat(
                      label: 'Avg Price',
                      value: Formatters.currency(
                        currencyState.convert(h.purchasePrice),
                        symbol: currencyState.symbol,
                      ),
                      color: colors.subtleText,
                    ),
                    _MiniStat(
                      label: 'ESG Score',
                      value: h.esgData.esgScore.toStringAsFixed(0),
                      color: scoreColor,
                    ),
                    _MiniStat(
                      label: 'CO₂',
                      value: '${h.esgData.co2Emissions.toStringAsFixed(0)}t',
                      color: h.esgData.co2Emissions > 100
                          ? colors.redScore
                          : colors.yellowScore,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    )
        .animate(target: isSkeleton ? 0 : 1, delay: (index * 80).ms)
        .fadeIn(duration: 400.ms)
        .slideY(begin: 0.3, end: 0, curve: Curves.easeOut);
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.label, required this.value, required this.color});
  final String label, value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium?.copyWith(fontSize: 10)),
        Text(value,
            style: theme.textTheme.titleMedium
                ?.copyWith(fontSize: 13, color: color)),
      ],
    );
  }
}

class _PortfolioEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.account_balance_wallet_rounded,
                  size: 48, color: Color(0xFF10B981)),
            ),
            const SizedBox(height: 24),
            Text('Empty Portfolio', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              'Go to Search and add stocks to start tracking your green investment journey',
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
