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

import 'search_bloc_test.mocks.dart';

@GenerateMocks([SearchStocks])
void main() {
  late MockSearchStocks mockSearchStocks;
  late SearchBloc searchBloc;

  const testStock = Stock(
    symbol: 'AAPL',
    name: 'Apple Inc.',
    price: 150.0,
    changePercent: 1.5,
    change: 2.25,
    volume: 100000,
    previousClose: 147.75,
  );

  setUp(() {
    mockSearchStocks = MockSearchStocks();
    searchBloc = SearchBloc(searchStocks: mockSearchStocks);
  });

  tearDown(() {
    searchBloc.close();
  });

  test('initial state is SearchInitial', () {
    expect(searchBloc.state, isA<SearchInitial>());
  });

  group('SearchQueryChanged', () {
    blocTest<SearchBloc, SearchState>(
      'emits [SearchInitial] when search query is empty',
      build: () => searchBloc,
      act: (bloc) => bloc.add(const SearchQueryChanged(query: '')),
      wait: const Duration(milliseconds: 500),
      expect: () => [isA<SearchInitial>()],
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchLoaded] on successful search',
      build: () {
        when(mockSearchStocks('AAPL'))
            .thenAnswer((_) async => const Right([testStock]));
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged(query: 'AAPL')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchLoaded>().having((s) => s.results.length, 'results length', 1),
      ],
      verify: (_) {
        verify(mockSearchStocks('AAPL')).called(1);
      },
    );

    blocTest<SearchBloc, SearchState>(
      'emits [SearchLoading, SearchError] when search fails',
      build: () {
        when(mockSearchStocks('FAIL'))
            .thenAnswer((_) async => const Left(ServerFailure('Search failed')));
        return searchBloc;
      },
      act: (bloc) => bloc.add(const SearchQueryChanged(query: 'FAIL')),
      wait: const Duration(milliseconds: 500),
      expect: () => [
        isA<SearchLoading>(),
        isA<SearchError>().having((s) => s.message, 'message', 'Search failed'),
      ],
    );
  });
}
