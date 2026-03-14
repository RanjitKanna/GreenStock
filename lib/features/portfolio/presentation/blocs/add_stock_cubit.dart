import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class AddStockState extends Equatable {
  const AddStockState({
    this.symbol = '',
    this.quantity,
    this.price,
    this.error,
    this.isFetchingPrice = false,
  });

  final String symbol;
  final double? quantity;
  final double? price;
  final String? error;
  final bool isFetchingPrice;

  AddStockState copyWith({
    String? symbol,
    double? quantity,
    double? price,
    String? error,
    bool? isFetchingPrice,
  }) {
    return AddStockState(
      symbol: symbol ?? this.symbol,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
      error: error, // If we don't pass error, it should be null (cleared)
      isFetchingPrice: isFetchingPrice ?? this.isFetchingPrice,
    );
  }

  @override
  List<Object?> get props => [symbol, quantity, price, error, isFetchingPrice];
}

class AddStockCubit extends Cubit<AddStockState> {
  AddStockCubit() : super(const AddStockState());

  void updateSymbol(String symbol) {
    emit(state.copyWith(symbol: symbol, error: null));
  }

  void updateQuantity(String value) {
    final qty = double.tryParse(value);
    emit(state.copyWith(quantity: qty, error: null));
  }

  void updatePrice(String value) {
    final price = double.tryParse(value);
    emit(state.copyWith(price: price, error: null));
  }

  void setPrice(double price) {
    emit(state.copyWith(price: price));
  }

  void setFetchingPrice(bool isFetching) {
    emit(state.copyWith(isFetchingPrice: isFetching));
  }

  void setError(String? error) {
    emit(state.copyWith(error: error));
  }

  bool validate() {
    if (state.symbol.isEmpty ||
        state.quantity == null ||
        state.quantity! <= 0 ||
        state.price == null ||
        state.price! <= 0) {
      setError('Please fill all fields with valid values');
      return false;
    }
    setError(null);
    return true;
  }
}
