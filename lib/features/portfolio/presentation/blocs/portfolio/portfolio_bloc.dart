import 'package:flutter_bloc/flutter_bloc.dart';
import 'portfolio_event.dart';
import 'portfolio_state.dart';
import '../../../domain/usecases/portfolio_usecases.dart';
import '../../../domain/usecases/calculate_green_score.dart';

class PortfolioBloc extends Bloc<PortfolioEvent, PortfolioState> {
  final GetPortfolio getPortfolio;
  final AddToPortfolio addToPortfolio;
  final RemoveFromPortfolio removeFromPortfolio;
  final CalculateGreenScore calculateGreenScore;

  PortfolioBloc({
    required this.getPortfolio,
    required this.addToPortfolio,
    required this.removeFromPortfolio,
    required this.calculateGreenScore,
  }) : super(PortfolioInitial()) {
    on<LoadPortfolio>(_onLoadPortfolio);
    on<RefreshPortfolio>(_onRefreshPortfolio);
    on<AddStockEvent>(_onAddStock);
    on<RemoveStockEvent>(_onRemoveStock);
  }

  Future<void> _onLoadPortfolio(
      LoadPortfolio event, Emitter<PortfolioState> emit) async {
    emit(PortfolioLoading());
    await _fetchPortfolio(emit);
  }

  Future<void> _onRefreshPortfolio(
      RefreshPortfolio event, Emitter<PortfolioState> emit) async {
    emit(PortfolioLoading());
    await _fetchPortfolio(emit);
  }

  Future<void> _onAddStock(
      AddStockEvent event, Emitter<PortfolioState> emit) async {
    final result =
        await addToPortfolio(event.symbol, event.quantity, event.price);
    result.fold(
      (failure) => emit(PortfolioError(message: failure.message)),
      (_) {
        emit(StockAddedSuccess(symbol: event.symbol));
        add(RefreshPortfolio());
      },
    );
  }

  Future<void> _onRemoveStock(
      RemoveStockEvent event, Emitter<PortfolioState> emit) async {
    final result = await removeFromPortfolio(event.symbol);
    result.fold(
      (failure) => emit(PortfolioError(message: failure.message)),
      (_) => add(RefreshPortfolio()),
    );
  }

  Future<void> _fetchPortfolio(Emitter<PortfolioState> emit) async {
    final result = await getPortfolio();
    result.fold(
      (failure) => emit(PortfolioError(message: failure.message)),
      (stocks) {
        final greenScore = calculateGreenScore(stocks);
        emit(PortfolioLoaded(portfolio: stocks, greenScore: greenScore));
      },
    );
  }
}
