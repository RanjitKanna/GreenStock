import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:green_stocks/core/network/currency_service.dart';
import 'package:green_stocks/core/utils/currency_cubit.dart';

@GenerateMocks([CurrencyService])
import 'currency_cubit_test.mocks.dart';

void main() {
  late MockCurrencyService mockCurrencyService;

  setUp(() {
    mockCurrencyService = MockCurrencyService();
  });

  group('CurrencyState', () {
    test('initial state is USD with rate 83.0', () {
      final cubit = CurrencyCubit(mockCurrencyService);
      addTearDown(cubit.close);

      expect(cubit.state.type, CurrencyType.usd);
      expect(cubit.state.rate, 83.0);
      expect(cubit.state.isLoading, false);
    });

    test('symbol returns \$ for USD', () {
      const state = CurrencyState(type: CurrencyType.usd, rate: 83.0);
      expect(state.symbol, '\$');
    });

    test('symbol returns ₹ for INR', () {
      const state = CurrencyState(type: CurrencyType.inr, rate: 83.0);
      expect(state.symbol, '₹');
    });

    test('convert returns raw value for USD', () {
      const state = CurrencyState(type: CurrencyType.usd, rate: 83.0);
      expect(state.convert(100), 100.0);
    });

    test('convert returns value * rate for INR', () {
      const state = CurrencyState(type: CurrencyType.inr, rate: 83.0);
      expect(state.convert(100), 8300.0);
    });

    test('copyWith preserves unmodified fields', () {
      const state = CurrencyState(type: CurrencyType.usd, rate: 83.0);
      final copied = state.copyWith(isLoading: true);
      expect(copied.type, CurrencyType.usd);
      expect(copied.rate, 83.0);
      expect(copied.isLoading, true);
    });

    test('props includes type, rate, isLoading', () {
      const state = CurrencyState(type: CurrencyType.usd, rate: 83.0);
      expect(state.props, [CurrencyType.usd, 83.0, false]);
    });
  });

  group('CurrencyCubit.toggleCurrency', () {
    blocTest<CurrencyCubit, CurrencyState>(
      'toggles from USD to INR',
      build: () => CurrencyCubit(mockCurrencyService),
      act: (cubit) => cubit.toggleCurrency(),
      expect: () => [
        const CurrencyState(type: CurrencyType.inr, rate: 83.0),
      ],
    );

    blocTest<CurrencyCubit, CurrencyState>(
      'toggles from INR back to USD',
      build: () => CurrencyCubit(mockCurrencyService),
      act: (cubit) {
        cubit.toggleCurrency(); // USD -> INR
        cubit.toggleCurrency(); // INR -> USD
      },
      expect: () => [
        const CurrencyState(type: CurrencyType.inr, rate: 83.0),
        const CurrencyState(type: CurrencyType.usd, rate: 83.0),
      ],
    );
  });

  group('CurrencyCubit.fetchRate', () {
    blocTest<CurrencyCubit, CurrencyState>(
      'emits loading then loaded with fetched rate',
      build: () {
        when(mockCurrencyService.getUsdToInrRate())
            .thenAnswer((_) async => 85.5);
        return CurrencyCubit(mockCurrencyService);
      },
      act: (cubit) => cubit.fetchRate(),
      expect: () => [
        const CurrencyState(
            type: CurrencyType.usd, rate: 83.0, isLoading: true),
        const CurrencyState(
            type: CurrencyType.usd, rate: 85.5, isLoading: false),
      ],
    );

    blocTest<CurrencyCubit, CurrencyState>(
      'calls getUsdToInrRate on the service',
      build: () {
        when(mockCurrencyService.getUsdToInrRate())
            .thenAnswer((_) async => 83.0);
        return CurrencyCubit(mockCurrencyService);
      },
      act: (cubit) => cubit.fetchRate(),
      verify: (_) {
        verify(mockCurrencyService.getUsdToInrRate()).called(1);
      },
    );
  });
}
