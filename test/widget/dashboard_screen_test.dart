import 'package:bloc_test/bloc_test.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:green_stocks/core/theme/app_theme.dart';
import 'package:green_stocks/core/theme/theme_cubit.dart';
import 'package:green_stocks/core/utils/currency_cubit.dart';
import 'package:green_stocks/features/portfolio/domain/entities/esg_data.dart';
import 'package:green_stocks/features/portfolio/domain/entities/portfolio_stock.dart';
import 'package:green_stocks/features/portfolio/domain/entities/stock.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/portfolio/portfolio_event.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/portfolio/portfolio_state.dart';
import 'package:green_stocks/features/portfolio/presentation/screens/dashboard/dashboard_screen.dart';

// ── Mock classes ──

class MockPortfolioBloc extends MockBloc<PortfolioEvent, PortfolioState>
    implements PortfolioBloc {}

class MockThemeCubit extends MockCubit<bool> implements ThemeCubit {}

class MockCurrencyCubit extends MockCubit<CurrencyState>
    implements CurrencyCubit {}

// ── Test data ──

const _testStock = Stock(
  symbol: 'AAPL',
  name: 'Apple Inc.',
  price: 150.0,
  change: 5.0,
  changePercent: 3.45,
  volume: 50000,
  previousClose: 145.0,
);

const _testEsg = EsgData(
  symbol: 'AAPL',
  esgScore: 78,
  environmentScore: 70,
  socialScore: 80,
  governanceScore: 75,
  co2Emissions: 45.0,
  sustainabilityRating: SustainabilityRating.excellent,
);

final _testHolding = PortfolioStock(
  stock: _testStock,
  esgData: _testEsg,
  quantity: 10,
  purchasePrice: 120.0,
);

// ── Helper ──

Widget _buildTestWidget({
  required MockPortfolioBloc portfolioBloc,
  required MockThemeCubit themeCubit,
  required MockCurrencyCubit currencyCubit,
}) {
  return ScreenUtilInit(
    designSize: const Size(375, 812),
    minTextAdapt: true,
    builder: (context, child) {
      return MaterialApp(
        theme: AppTheme.dark,
        home: MultiBlocProvider(
          providers: [
            BlocProvider<PortfolioBloc>.value(value: portfolioBloc),
            BlocProvider<ThemeCubit>.value(value: themeCubit),
            BlocProvider<CurrencyCubit>.value(value: currencyCubit),
          ],
          child: const Scaffold(body: DashboardScreen()),
        ),
      );
    },
  );
}

void main() {
  late MockPortfolioBloc mockPortfolioBloc;
  late MockThemeCubit mockThemeCubit;
  late MockCurrencyCubit mockCurrencyCubit;

  setUp(() {
    mockPortfolioBloc = MockPortfolioBloc();
    mockThemeCubit = MockThemeCubit();
    mockCurrencyCubit = MockCurrencyCubit();

    // Set up default states for theme and currency cubits
    whenListen(
      mockThemeCubit,
      const Stream<bool>.empty(),
      initialState: false, // light mode
    );
    whenListen(
      mockCurrencyCubit,
      const Stream<CurrencyState>.empty(),
      initialState: const CurrencyState(type: CurrencyType.usd, rate: 83.0),
    );
  });

  group('DashboardScreen — loading state', () {
    testWidgets('shows skeleton shimmer when PortfolioLoading',
        (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState: PortfolioLoading(),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      // Advance past animation frames — skeletonizer has infinite shimmer
      // so pumpAndSettle would time out. Just pump enough to render.
      await tester.pump(const Duration(milliseconds: 500));

      // The screen should be rendering (no crash) in loading state
      expect(find.byType(DashboardScreen), findsOneWidget);
    });
  });

  group('DashboardScreen — empty state', () {
    testWidgets('shows "No stocks yet" when portfolio is empty',
        (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState: const PortfolioLoaded(portfolio: [], greenScore: 100),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('No stocks yet'), findsOneWidget);
    });
  });

  group('DashboardScreen — loaded state', () {
    testWidgets('renders Green Score card with CircularPercentIndicator',
        (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            PortfolioLoaded(portfolio: [_testHolding], greenScore: 85),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(CircularPercentIndicator), findsOneWidget);
      expect(find.text('85'), findsOneWidget);
      expect(find.text('Green Score'), findsOneWidget);
      expect(find.text('Excellent'), findsOneWidget);
    });

    testWidgets('renders summary row with Portfolio, CO₂, and P&L tiles',
        (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            PortfolioLoaded(portfolio: [_testHolding], greenScore: 85),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Portfolio'), findsOneWidget);
      expect(find.text('Total CO₂'), findsOneWidget);
      expect(find.text('P&L'), findsOneWidget);
    });

    testWidgets('renders CO₂ Breakdown section with BarChart',
        (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            PortfolioLoaded(portfolio: [_testHolding], greenScore: 85),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('CO₂ Breakdown'), findsOneWidget);
      expect(find.byType(BarChart), findsOneWidget);
    });

    testWidgets('renders Your Holdings section with stock info',
        (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            PortfolioLoaded(portfolio: [_testHolding], greenScore: 85),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Your Holdings'), findsOneWidget);
      expect(find.text('AAPL'), findsAtLeastNWidgets(1));
      expect(find.text('Apple Inc.'), findsOneWidget);
      expect(find.text('ESG 78'), findsOneWidget);
    });

    testWidgets('shows "Fair" band for green score 50', (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            PortfolioLoaded(portfolio: [_testHolding], greenScore: 50),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Fair'), findsOneWidget);
    });

    testWidgets('shows "Poor" band for green score 20', (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            PortfolioLoaded(portfolio: [_testHolding], greenScore: 20),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Poor'), findsOneWidget);
    });
  });

  group('DashboardScreen — error state', () {
    testWidgets('shows error message when PortfolioError', (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            const PortfolioError(message: 'Connection timed out'),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      // flutter_animate FAB entrance animation leaves pending timers
      // Pump enough frames to render the error UI without needing to settle
      await tester.pump(const Duration(milliseconds: 700));

      expect(find.text('Failed to load portfolio'), findsOneWidget);
      expect(find.text('Connection timed out'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline_rounded), findsOneWidget);
    });
  });

  group('DashboardScreen — FAB', () {
    testWidgets('Add Stock FAB is present', (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            const PortfolioLoaded(portfolio: [], greenScore: 100),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Add Stock'), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });

  group('DashboardScreen — app bar', () {
    testWidgets('displays app title', (tester) async {
      whenListen(
        mockPortfolioBloc,
        const Stream<PortfolioState>.empty(),
        initialState:
            const PortfolioLoaded(portfolio: [], greenScore: 100),
      );

      await tester.pumpWidget(_buildTestWidget(
        portfolioBloc: mockPortfolioBloc,
        themeCubit: mockThemeCubit,
        currencyCubit: mockCurrencyCubit,
      ));
      await tester.pumpAndSettle();

      expect(find.text('Green Stock'), findsOneWidget);
    });
  });
}
