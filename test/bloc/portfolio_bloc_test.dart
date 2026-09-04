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

@GenerateMocks([GetPortfolio, AddToPortfolio, RemoveFromPortfolio, CalculateGreenScore])
import 'portfolio_bloc_test.mocks.dart';

void main() {
  late MockGetPortfolio mockGetPortfolio;
  late MockAddToPortfolio mockAddToPortfolio;
  late MockRemoveFromPortfolio mockRemoveFromPortfolio;
  late MockCalculateGreenScore mockCalculateGreenScore;

  setUp(() {
    mockGetPortfolio = MockGetPortfolio();
    mockAddToPortfolio = MockAddToPortfolio();
    mockRemoveFromPortfolio = MockRemoveFromPortfolio();
    mockCalculateGreenScore = MockCalculateGreenScore();
  });

  final tPortfolio = [
    PortfolioStock(
      stock: const Stock(
        symbol: 'AAPL',
        name: 'Apple Inc.',
        price: 150.0,
        change: 5.0,
        changePercent: 3.45,
        volume: 50000,
        previousClose: 145.0,
      ),
      esgData: const EsgData(
        symbol: 'AAPL',
        esgScore: 75,
        environmentScore: 70,
        socialScore: 80,
        governanceScore: 75,
        co2Emissions: 45.0,
        sustainabilityRating: SustainabilityRating.excellent,
      ),
      quantity: 10,
      purchasePrice: 120.0,
    ),
  ];

  const tGreenScore = 85.0;

  PortfolioBloc buildBloc() => PortfolioBloc(
        getPortfolio: mockGetPortfolio,
        addToPortfolio: mockAddToPortfolio,
        removeFromPortfolio: mockRemoveFromPortfolio,
        calculateGreenScore: mockCalculateGreenScore,
      );

  group('LoadPortfolio', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits [Loading, Loaded] when getPortfolio succeeds',
      build: () {
        when(mockGetPortfolio()).thenAnswer((_) async => Right(tPortfolio));
        when(mockCalculateGreenScore(tPortfolio)).thenReturn(tGreenScore);
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadPortfolio()),
      expect: () => [
        PortfolioLoading(),
        PortfolioLoaded(portfolio: tPortfolio, greenScore: tGreenScore),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits [Loading, Error] when getPortfolio fails',
      build: () {
        when(mockGetPortfolio()).thenAnswer(
            (_) async => const Left(ServerFailure('Server error')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(LoadPortfolio()),
      expect: () => [
        PortfolioLoading(),
        const PortfolioError(message: 'Server error'),
      ],
    );
  });

  group('RefreshPortfolio', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits [Loading, Loaded] on successful refresh',
      build: () {
        when(mockGetPortfolio()).thenAnswer((_) async => Right(tPortfolio));
        when(mockCalculateGreenScore(tPortfolio)).thenReturn(tGreenScore);
        return buildBloc();
      },
      act: (bloc) => bloc.add(RefreshPortfolio()),
      expect: () => [
        PortfolioLoading(),
        PortfolioLoaded(portfolio: tPortfolio, greenScore: tGreenScore),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits [Loading, Error] when refresh fails',
      build: () {
        when(mockGetPortfolio()).thenAnswer(
            (_) async => const Left(NetworkFailure('No connection')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(RefreshPortfolio()),
      expect: () => [
        PortfolioLoading(),
        const PortfolioError(message: 'No connection'),
      ],
    );
  });

  group('AddStockEvent', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'emits [StockAddedSuccess] then refreshes on successful add',
      build: () {
        when(mockAddToPortfolio('AAPL', 5.0, 130.0))
            .thenAnswer((_) async => const Right(unit));
        when(mockGetPortfolio()).thenAnswer((_) async => Right(tPortfolio));
        when(mockCalculateGreenScore(tPortfolio)).thenReturn(tGreenScore);
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AddStockEvent(symbol: 'AAPL', quantity: 5, price: 130),
      ),
      expect: () => [
        const StockAddedSuccess(symbol: 'AAPL'),
        PortfolioLoading(),
        PortfolioLoaded(portfolio: tPortfolio, greenScore: tGreenScore),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits [Error] when addToPortfolio fails',
      build: () {
        when(mockAddToPortfolio('AAPL', 5.0, 130.0)).thenAnswer(
            (_) async => const Left(CacheFailure('Storage full')));
        return buildBloc();
      },
      act: (bloc) => bloc.add(
        const AddStockEvent(symbol: 'AAPL', quantity: 5, price: 130),
      ),
      expect: () => [
        const PortfolioError(message: 'Storage full'),
      ],
    );
  });

  group('RemoveStockEvent', () {
    blocTest<PortfolioBloc, PortfolioState>(
      'triggers refresh on successful removal',
      build: () {
        when(mockRemoveFromPortfolio('AAPL'))
            .thenAnswer((_) async => const Right(unit));
        when(mockGetPortfolio())
            .thenAnswer((_) async => const Right(<PortfolioStock>[]));
        when(mockCalculateGreenScore(const <PortfolioStock>[]))
            .thenReturn(100.0);
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const RemoveStockEvent(symbol: 'AAPL')),
      expect: () => [
        PortfolioLoading(),
        const PortfolioLoaded(portfolio: [], greenScore: 100.0),
      ],
    );

    blocTest<PortfolioBloc, PortfolioState>(
      'emits [Error] when removeFromPortfolio fails',
      build: () {
        when(mockRemoveFromPortfolio('AAPL')).thenAnswer(
            (_) async => const Left(NotFoundFailure('Not found')));
        return buildBloc();
      },
      act: (bloc) =>
          bloc.add(const RemoveStockEvent(symbol: 'AAPL')),
      expect: () => [
        const PortfolioError(message: 'Not found'),
      ],
    );
  });

  group('PortfolioState equatable', () {
    test('PortfolioLoaded instances with same data are equal', () {
      final a = PortfolioLoaded(portfolio: tPortfolio, greenScore: tGreenScore);
      final b = PortfolioLoaded(portfolio: tPortfolio, greenScore: tGreenScore);
      expect(a, b);
    });

    test('PortfolioError instances with same message are equal', () {
      const a = PortfolioError(message: 'err');
      const b = PortfolioError(message: 'err');
      expect(a, b);
    });

    test('StockAddedSuccess instances with same symbol are equal', () {
      const a = StockAddedSuccess(symbol: 'X');
      const b = StockAddedSuccess(symbol: 'X');
      expect(a, b);
    });
  });

  group('PortfolioEvent equatable', () {
    test('AddStockEvent instances with same data are equal', () {
      const a = AddStockEvent(symbol: 'X', quantity: 1, price: 10);
      const b = AddStockEvent(symbol: 'X', quantity: 1, price: 10);
      expect(a, b);
    });

    test('RemoveStockEvent instances with same symbol are equal', () {
      const a = RemoveStockEvent(symbol: 'X');
      const b = RemoveStockEvent(symbol: 'X');
      expect(a, b);
    });
  });
}
