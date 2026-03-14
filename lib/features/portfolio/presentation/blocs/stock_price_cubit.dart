import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/stock.dart';
import '../../domain/usecases/get_stock_price.dart';

abstract class StockPriceState extends Equatable {
  const StockPriceState();
  
  @override
  List<Object?> get props => [];
}

class StockPriceInitial extends StockPriceState {}

class StockPriceLoading extends StockPriceState {}

class StockPriceLoaded extends StockPriceState {
  final Stock stock;

  const StockPriceLoaded({required this.stock});

  @override
  List<Object?> get props => [stock];
}

class StockPriceError extends StockPriceState {
  final String message;

  const StockPriceError({required this.message});

  @override
  List<Object?> get props => [message];
}

class StockPriceCubit extends Cubit<StockPriceState> {
  final GetStockPrice getStockPrice;

  StockPriceCubit({required this.getStockPrice}) : super(StockPriceInitial());

  Future<void> fetchPrice(String symbol) async {
    emit(StockPriceLoading());
    final result = await getStockPrice(symbol);
    result.fold(
      (failure) => emit(StockPriceError(message: failure.message)),
      (stock) => emit(StockPriceLoaded(stock: stock)),
    );
  }
}
