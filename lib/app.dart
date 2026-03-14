import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_cubit.dart';
import 'features/portfolio/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'features/portfolio/presentation/blocs/portfolio/portfolio_event.dart';
import 'features/portfolio/presentation/blocs/search/search_bloc.dart';
import 'features/portfolio/presentation/screens/dashboard/dashboard_screen.dart';
import 'features/portfolio/presentation/screens/search/search_screen.dart';
import 'features/portfolio/presentation/screens/portfolio/portfolio_screen.dart';
import 'core/theme/navigation_cubit.dart';
import 'core/utils/currency_cubit.dart';
import 'core/di/service_locator.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/widgets/tappable_scale.dart';

class GreenStockApp extends StatelessWidget {
  const GreenStockApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => NavigationCubit()),
        BlocProvider(
          create: (_) => PortfolioBloc(
            getPortfolio: sl(),
            addToPortfolio: sl(),
            removeFromPortfolio: sl(),
            calculateGreenScore: sl(),
          )..add(LoadPortfolio()),
        ),
        BlocProvider(
          create: (_) => SearchBloc(searchStocks: sl()),
        ),
        BlocProvider(
          create: (_) => sl<CurrencyCubit>()..fetchRate(),
        ),
      ],
      child: BlocBuilder<ThemeCubit, bool>(
        builder: (context, isDark) {
          return AnimatedTheme(
            data: isDark ? AppTheme.dark : AppTheme.light,
            curve: Curves.easeInOut,
            duration: const Duration(milliseconds: 400),
            child: ScreenUtilInit(
              designSize: const Size(375, 812),
              minTextAdapt: true,
              splitScreenMode: true,
              builder: (context, child) {
                return MaterialApp(
                  title: 'GreenStock — Eco Portfolio',
                  theme: AppTheme.light,
                  darkTheme: AppTheme.dark,
                  themeMode: isDark ? ThemeMode.dark : ThemeMode.light,
                  debugShowCheckedModeBanner: false,
                  home: child,
                );
              },
              child: const MainShell(),
            ),
          );
        },
      ),
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key});

  final List<Widget> _pages = const [
    DashboardScreen(),
    SearchScreen(),
    PortfolioScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NavigationCubit, int>(
      builder: (context, currentIndex) {
        return Scaffold(
          body: IndexedStack(
            index: currentIndex,
            children: _pages,
          ),
          bottomNavigationBar: _ModernNavBar(
            currentIndex: currentIndex,
            onTap: (index) => context.read<NavigationCubit>().setTab(index),
          ),
        );
      },
    );
  }
}

class _ModernNavBar extends StatelessWidget {
  const _ModernNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.extension<AppColors>()!;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 12 + bottomPadding),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.dividerTheme.color ?? Colors.transparent,
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _NavBarItem(
            icon: Icons.dashboard_rounded,
            label: 'Dashboard',
            isSelected: currentIndex == 0,
            onTap: () => onTap(0),
            colors: colors,
          ),
          _NavBarItem(
            icon: Icons.search_rounded,
            label: 'Search',
            isSelected: currentIndex == 1,
            onTap: () => onTap(1),
            colors: colors,
          ),
          _NavBarItem(
            icon: Icons.account_balance_wallet_rounded,
            label: 'Portfolio',
            isSelected: currentIndex == 2,
            onTap: () => onTap(2),
            colors: colors,
          ),
        ],
      ),
    );
  }
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    required this.colors,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final AppColors colors;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? colors.gainColor : const Color(0xFF4A5668);

    return TappableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colors.gainColor.withValues(alpha: 0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeInOutCubic,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: isSelected ? 1.0 : 0.0,
                child: isSelected
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          label,
                          style: theme.textTheme.labelLarge?.copyWith(
                            color: color,
                            fontWeight: FontWeight.w700,
                            letterSpacing: -0.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
