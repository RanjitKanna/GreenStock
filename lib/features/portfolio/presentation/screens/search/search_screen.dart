import 'package:skeletonizer/skeletonizer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../../../core/utils/formatters.dart';
import '../../../../../core/widgets/tappable_scale.dart';
import '../../../domain/entities/stock.dart';
import '../../blocs/search/search_bloc.dart';
import '../../blocs/search/search_event.dart';
import '../../blocs/search/search_state.dart';
import '../add_stock/add_stock_sheet.dart';
import '../../blocs/portfolio/portfolio_bloc.dart';
import '../../blocs/portfolio/portfolio_state.dart';
import '../../../../../core/widgets/green_toast.dart';
import '../../../../../core/utils/currency_cubit.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).extension<AppColors>()!;
    final theme = Theme.of(context);

    final dummyStocks = List.generate(
      5,
      (i) => const Stock(
        symbol: 'SKELETON',
        name: 'Skeleton Company Name',
        price: 150.0,
        change: 2.5,
        changePercent: 1.5,
        volume: 1000,
        previousClose: 148.5,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: BlocListener<PortfolioBloc, PortfolioState>(
          listener: (context, state) {
            if (state is StockAddedSuccess) {
              GreenToast.show(
                context,
                message: '${state.symbol} added to portfolio!',
              );
            }
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Skeleton.keep(
                  child: Text('Search Stocks',
                      style: theme.textTheme.displayMedium?.copyWith(
                          fontSize: 26, fontWeight: FontWeight.bold)),
                ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2, end: 0),
                const SizedBox(height: 4),
                const Skeleton.keep(
                  child: Text('Find stocks and check their ESG impact',
                      style: TextStyle(fontSize: 14)),
                ).animate().fadeIn(delay: 100.ms, duration: 400.ms),
                const SizedBox(height: 20),
                BlocBuilder<SearchBloc, SearchState>(
                  builder: (context, state) {
                    return Skeleton.keep(
                      child: TextField(
                        onChanged: (v) => context
                            .read<SearchBloc>()
                            .add(SearchQueryChanged(query: v)),
                        decoration: const InputDecoration(
                          prefixIcon: Icon(Icons.search_rounded),
                          hintText: 'Search by symbol or name (e.g. AAPL)',
                          suffixIcon: Icon(Icons.mic_rounded, size: 20),
                        ),
                      ),
                    )
                        .animate()
                        .fadeIn(delay: 150.ms, duration: 400.ms)
                        .slideY(begin: 0.2, end: 0);
                  },
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: BlocBuilder<SearchBloc, SearchState>(
                    builder: (context, state) {
                      if (state is SearchInitial) {
                        return _PopularStocks(colors: colors);
                      } else if (state is SearchLoading) {
                        return Skeletonizer(
                          enabled: true,
                          child: ListView.builder(
                            itemCount: dummyStocks.length,
                            itemBuilder: (ctx, i) => _SearchResultTile(
                              stock: dummyStocks[i],
                              colors: colors,
                              index: i,
                              isSkeleton: true,
                            ),
                          ),
                        );
                      } else if (state is SearchError) {
                        return Center(child: Text(state.message));
                      } else if (state is SearchLoaded) {
                        final stocks = state.results;
                        if (stocks.isEmpty) {
                          return Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.search_off_rounded,
                                    size: 48, color: colors.subtleText),
                                const SizedBox(height: 12),
                                Text('No results found',
                                    style: theme.textTheme.titleMedium),
                              ],
                            ).animate().fadeIn(),
                          );
                        }
                        return ListView.builder(
                          itemCount: stocks.length,
                          itemBuilder: (ctx, i) => _SearchResultTile(
                            stock: stocks[i],
                            colors: colors,
                            index: i,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PopularStocks extends StatelessWidget {
  const _PopularStocks({required this.colors});
  final AppColors colors;

  static const _popular = [
    ('AAPL', 'Apple Inc.'),
    ('MSFT', 'Microsoft'),
    ('TSLA', 'Tesla'),
    ('GOOGL', 'Alphabet'),
    ('NVDA', 'NVIDIA'),
    ('NEE', 'NextEra Energy'),
    ('ENPH', 'Enphase'),
    ('META', 'Meta'),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Popular Stocks', style: theme.textTheme.titleMedium)
            .animate()
            .fadeIn(delay: 200.ms),
        const SizedBox(height: 12),
        Expanded(
          child: GridView.count(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _popular.asMap().entries.map((e) {
              return _PopularChip(
                symbol: e.value.$1,
                name: e.value.$2,
                colors: colors,
                index: e.key,
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

class _PopularChip extends StatelessWidget {
  const _PopularChip({
    required this.symbol,
    required this.name,
    required this.colors,
    required this.index,
  });
  final String symbol, name;
  final AppColors colors;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TappableScale(
      onTap: () {
        context.read<SearchBloc>().add(SearchQueryChanged(query: symbol));
      },
      child: Card(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.show_chart_rounded, size: 16, color: colors.gainColor),
              const SizedBox(width: 6),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(symbol,
                        style: theme.textTheme.titleMedium
                            ?.copyWith(fontSize: 14)),
                    Text(name,
                        style:
                            theme.textTheme.bodyMedium?.copyWith(fontSize: 11),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate(delay: (index * 60).ms)
        .fadeIn(duration: 350.ms)
        .slideX(begin: 0.3, end: 0, curve: Curves.easeOut);
  }
}

class _SearchResultTile extends StatelessWidget {
  const _SearchResultTile({
    required this.stock,
    required this.colors,
    required this.index,
    this.isSkeleton = false,
  });
  final Stock stock;
  final AppColors colors;
  final int index;
  final bool isSkeleton;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isGain = stock.changePercent >= 0;

    return TappableScale(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddStockSheet(
            prefilledSymbol: stock.symbol,
            prefilledPrice: stock.price,
          ),
        );
      },
      child: Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [
                    colors.gainColor.withValues(alpha: 0.2),
                    colors.gainColor.withValues(alpha: 0.08),
                  ]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    stock.symbol.isNotEmpty ? stock.symbol[0] : '?',
                    style: TextStyle(
                      color: colors.gainColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(stock.symbol, style: theme.textTheme.titleMedium),
                    Text(stock.name,
                        style: theme.textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              BlocBuilder<CurrencyCubit, CurrencyState>(
                builder: (context, currencyState) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (stock.price > 0)
                        Text(
                          Formatters.currency(
                            currencyState.convert(stock.price),
                            symbol: currencyState.symbol,
                          ),
                          style: theme.textTheme.titleMedium,
                        ),
                      if (stock.changePercent != 0)
                        Text(
                          Formatters.percent(stock.changePercent),
                          style: TextStyle(
                            color: isGain ? colors.gainColor : colors.lossColor,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      const SizedBox(height: 4),
                      TappableScale(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            isScrollControlled: true,
                            backgroundColor: Colors.transparent,
                            builder: (_) => AddStockSheet(
                              prefilledSymbol: stock.symbol,
                              prefilledPrice: stock.price,
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.gainColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text('+ Add',
                              style: TextStyle(
                                color: colors.gainColor,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              )),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    )
        .animate(target: isSkeleton ? 0 : 1, delay: (index * 70).ms)
        .fadeIn(duration: 350.ms)
        .slideY(begin: 0.2, end: 0, curve: Curves.easeOut);
  }
}
