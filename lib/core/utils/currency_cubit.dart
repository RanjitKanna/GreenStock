import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../network/currency_service.dart';

enum CurrencyType { usd, inr }

class CurrencyState extends Equatable {
  final CurrencyType type;
  final double rate;
  final bool isLoading;

  const CurrencyState({
    required this.type,
    required this.rate,
    this.isLoading = false,
  });

  String get symbol => type == CurrencyType.usd ? '\$' : '₹';

  double convert(double value) {
    if (type == CurrencyType.usd) {
      return value;
    } else {
      return value * rate;
    }
  }

  @override
  List<Object?> get props => [type, rate, isLoading];

  CurrencyState copyWith({
    CurrencyType? type,
    double? rate,
    bool? isLoading,
  }) {
    return CurrencyState(
      type: type ?? this.type,
      rate: rate ?? this.rate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CurrencyCubit extends Cubit<CurrencyState> {
  final CurrencyService _currencyService;

  CurrencyCubit(this._currencyService)
      : super(const CurrencyState(type: CurrencyType.usd, rate: 83.0));

  Future<void> fetchRate() async {
    emit(state.copyWith(isLoading: true));
    final rate = await _currencyService.getUsdToInrRate();
    emit(state.copyWith(rate: rate, isLoading: false));
  }

  void toggleCurrency() {
    final nextType =
        state.type == CurrencyType.usd ? CurrencyType.inr : CurrencyType.usd;
    emit(state.copyWith(type: nextType));
  }
}
