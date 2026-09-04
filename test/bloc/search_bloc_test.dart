import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_stocks/core/error/failures.dart';
import 'package:green_stocks/features/portfolio/domain/entities/stock.dart';
import 'package:green_stocks/features/portfolio/domain/usecases/search_stocks.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/search/search_bloc.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/search/search_event.dart';
import 'package:green_stocks/features/portfolio/presentation/blocs/search/search_state.dart';

@GenerateMocks([SearchStocks])
import 'search_bloc_test.mocks.dart';

void main() {
  late MockSearchStocks mockSearchStocks;

  setUp(() {
    mockSearchStocks = MockSearchStocks();
  });

  final tStocks = [
    const Stock(
      symbol: 'AAPL',
      name: 'Apple Inc.',
      price: 150.0,
      change: 5.0,
      changePercent: 3.45,
      volume: 50000,
      previousClose: 145.0,
    ),
    const Stock(
      symbol: 'AMZN',
      name: 'Amazon.com Inc.',
      price: 3200.0,
      change: 50.0,
      changePercent: 1.59,
      volume: 30000,
      previousClose: 3150.0,
    ),
  ];

  group('SearchBloc', () {
    test('initial state is SearchInitial', () {
      final bloc = SearchBloc(searchStocks: mockSearchStocks);
      addTearDown(bloc.close);
      expect(bloc.state, SearchInitial());
    });

    blocTest<SearchBloc, SearchState>(
      'emits SearchInitial when query is empty',
      build: () => SearchBloc(searchStocks: mockSearchStocks),
      act: (bloc) => bloc.add(const SearchQueryChanged(query: '')),
      wait: const Duration(milliseconds: 500),
      expect: () => [SearchInitial()],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [Loading, Loaded] on successful search',
      build: () {
        when(mockSearchStocks('apple'))
            .thenAnswer((_) async => Right(tStocks));
        return SearchBloc(searchStocks: mockSearchStocks);
      },
      act: (bloc) =>
          bloc.add(const SearchQueryChanged(query: 'apple')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        SearchLoading(),
        SearchLoaded(results: tStocks),
      ],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [Loading, Error] when search fails',
      build: () {
        when(mockSearchStocks('fail')).thenAnswer(
            (_) async => const Left(NetworkFailure('No internet')));
        return SearchBloc(searchStocks: mockSearchStocks);
      },
      act: (bloc) =>
          bloc.add(const SearchQueryChanged(query: 'fail')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        SearchLoading(),
        const SearchError(message: 'No internet'),
      ],
    );
  });

  group('SearchState equatable', () {
    test('SearchLoaded instances with same results are equal', () {
      final a = SearchLoaded(results: tStocks);
      final b = SearchLoaded(results: tStocks);
      expect(a, b);
    });

    test('SearchError instances with same message are equal', () {
      const a = SearchError(message: 'err');
      const b = SearchError(message: 'err');
      expect(a, b);
    });
  });

  group('SearchEvent equatable', () {
    test('SearchQueryChanged instances with same query are equal', () {
      const a = SearchQueryChanged(query: 'test');
      const b = SearchQueryChanged(query: 'test');
      expect(a, b);
    });
  });
}
