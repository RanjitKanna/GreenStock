import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'search_event.dart';
import 'search_state.dart';
import '../../../domain/usecases/search_stocks.dart';

EventTransformer<T> debounce<T>(Duration duration) {
  return (events, mapper) => events.debounceTime(duration).flatMap(mapper);
}

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  final SearchStocks searchStocks;

  SearchBloc({required this.searchStocks}) : super(SearchInitial()) {
    on<SearchQueryChanged>(
      _onSearchQueryChanged,
      transformer: debounce(const Duration(milliseconds: 400)),
    );
  }

  Future<void> _onSearchQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    if (event.query.isEmpty) {
      emit(SearchInitial());
      return;
    }

    emit(SearchLoading());
    final result = await searchStocks(event.query);
    result.fold(
      (failure) => emit(SearchError(message: failure.message)),
      (stocks) => emit(SearchLoaded(results: stocks)),
    );
  }
}
