import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_stocks/core/error/failures.dart';
import 'package:green_stocks/features/portfolio/domain/entities/esg_data.dart';
import 'package:green_stocks/features/portfolio/domain/entities/portfolio_stock.dart';
import 'package:green_stocks/features/portfolio/domain/entities/stock.dart';
import 'package:green_stocks/features/portfolio/domain/usecases/calculate_green_score.dart';
import 'package:green_stocks/features/portfolio/domain/usecases/portfolio_usecases.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/portfolio/portfolio_bloc.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/portfolio/portfolio_event.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/portfolio/portfolio_state.dart';

import 'portfolio_bloc_test.mocks.dart';

@GenerateMocks([
  GetPortfolio,
  AddToPortfolio,
  RemoveFromPortfolio,
  CalculateGreenScore,
])
void main() {
  late MockGetPortfolio mockGetPortfolio;
  late MockAddToPortfolio mockAddToPortfolio;
  late MockRemoveFromPortfolio mockRemoveFromPortfolio;
  late MockCalculateGreenScore mockCalculateGreenScore;
  late PortfolioBloc portfolioBloc;

  const testStock = Stock(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    price: 150.0,
    changePercent: 1.5,
    change: 2.25,
    volume: 100000,
    previousClose: 147.75,
  );

  const testEsg = EsgData(
    symbol: 'AAPL',
    esgScore: 80.0,
    environmentScore: 85.0,
    socialScore: 75.0,
    governanceScore: 80.0,
    co2Emissions: 10.0,
    sustainabilityRating: SustainabilityRating.excellent,
  );

  const testPortfolio = [
    PortfolioStock(
      stock: testStock,
      esgData: testEsg,
      quantity: 5.0,
      purchasePrice: 140.0,
    ),
  ];

  setUp(() {
    mockGetPortfolio = MockGetPortfolio();
    mockAddToPortfolio = MockAddToPortfolio();
    mockRemoveFromPortfolio = MockRemoveFromPortfolio();
    mockCalculateGreenScore = MockCalculateGreenScore();

    portfolioBloc = PortfolioBloc(
      getPortfolio: mockGetPortfolio,
      addToPortfolio: mockAddToPortfolio,
      removeFromPortfolio: mockRemoveFromPortfolio,
      calculateGreenScore: mockCalculateGreenScore,
    );
  });

  tearDown(() {
    portfolioBloc.close();
  });

  test('initial state should be PortfolioInitial', () {
    expect(portfolioBloc.state, isA<PortfolioInitial>());
  });

  group('LoadPortfolio', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits [PortfolioLoading, PortfolioLoaded] on successful fetch',
      build: () {
        when(mockGetPortfolio()).thenAnswer((_) async => const Right(testPortfolio));
        when(mockCalculateGreenScore(any)).thenReturn(85.0);
        return portfolioBloc;
      },
      act: (bloc) => bloc.add(LoadPortfolio()),
      expect: () => [
        isA<PortfolioLoading>(),
        isA<PortfolioLoaded>()
            .having((s) => s.portfolio.length, 'portfolio length', 1)
            .having((s) => s.greenScore, 'green score', 85.0),
      ],
      verify: (_) {
        verify(mockGetPortfolio()).called(1);
        verify(mockCalculateGreenScore(testPortfolio)).called(1);
      },
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits [PortfolioLoading, PortfolioError] when fetch fails',
      build: () {
        when(mockGetPortfolio())
            .thenAnswer((_) async => const Left(ServerFailure('Network error')));
        return portfolioBloc;
      },
      act: (bloc) => bloc.add(LoadPortfolio()),
      expect: () => [
        isA<PortfolioLoading>(),
        isA<PortfolioError>().having((s) => s.message, 'message', 'Network error'),
      ],
    );
  });

  group('RefreshPortfolio', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits [PortfolioLoading, PortfolioLoaded] when refreshing',
      build: () {
        when(mockGetPortfolio()).thenAnswer((_) async => const Right(testPortfolio));
        when(mockCalculateGreenScore(any)).thenReturn(85.0);
        return portfolioBloc;
      },
      act: (bloc) => bloc.add(RefreshPortfolio()),
      expect: () => [
        isA<PortfolioLoading>(),
        isA<PortfolioLoaded>(),
      ],
    );
  });

  group('AddStockEvent', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits [StockAddedSuccess, PortfolioLoading, PortfolioLoaded] on success',
      build: () {
        when(mockAddToPortfolio('AAPL', 5.0, 150.0))
            .thenAnswer((_) async => const Right(unit));
        when(mockGetPortfolio()).thenAnswer((_) async => const Right(testPortfolio));
        when(mockCalculateGreenScore(any)).thenReturn(85.0);
        return portfolioBloc;
      },
      act: (bloc) => bloc.add(const AddStockEvent(symbol: 'AAPL', quantity: 5.0, price: 150.0)),
      expect: () => [
        isA<StockAddedSuccess>().having((s) => s.symbol, 'symbol', 'AAPL'),
        isA<PortfolioLoading>(),
        isA<PortfolioLoaded>(),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits [PortfolioError] when adding stock fails',
      build: () {
        when(mockAddToPortfolio('AAPL', 5.0, 150.0))
            .thenAnswer((_) async => const Left(ServerFailure('Failed to add')));
        return portfolioBloc;
      },
      act: (bloc) => bloc.add(const AddStockEvent(symbol: 'AAPL', quantity: 5.0, price: 150.0)),
      expect: () => [
        isA<PortfolioError>().having((s) => s.message, 'message', 'Failed to add'),
      ],
    );
  });

  group('RemoveStockEvent', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'calls RefreshPortfolio and emits [PortfolioLoading, PortfolioLoaded] on success',
      build: () {
        when(mockRemoveFromPortfolio('AAPL'))
            .thenAnswer((_) async => const Right(unit));
        when(mockGetPortfolio()).thenAnswer((_) async => const Right(testPortfolio));
        when(mockCalculateGreenScore(any)).thenReturn(85.0);
        return portfolioBloc;
      },
      act: (bloc) => bloc.add(const RemoveStockEvent(symbol: 'AAPL')),
      expect: () => [
        isA<PortfolioLoading>(),
        isA<PortfolioLoaded>(),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits [PortfolioError] when removal fails',
      build: () {
        when(mockRemoveFromPortfolio('AAPL'))
            .thenAnswer((_) async => const Left(ServerFailure('Failed to remove')));
        return portfolioBloc;
      },
      act: (bloc) => bloc.add(const RemoveStockEvent(symbol: 'AAPL')),
      expect: () => [
        isA<PortfolioError>().having((s) => s.message, 'message', 'Failed to remove'),
      ],
    );
  });
}
