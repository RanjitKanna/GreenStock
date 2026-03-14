import 'package:get_it/get_it.dart';
import '../../features/portfolio/data/datasources/esg_datasource.dart';
import '../network/currency_service.dart';
import '../utils/currency_cubit.dart';
import '../../features/portfolio/data/datasources/portfolio_local_ds.dart';
import '../../features/portfolio/data/datasources/stock_remote_ds.dart';
import '../../features/portfolio/data/repositories/esg_repo_impl.dart';
import '../../features/portfolio/data/repositories/portfolio_repo_impl.dart';
import '../../features/portfolio/data/repositories/stock_repo_impl.dart';
import '../../features/portfolio/domain/repositories/i_esg_repository.dart';
import '../../features/portfolio/domain/repositories/i_portfolio_repository.dart';
import '../../features/portfolio/domain/repositories/i_stock_repository.dart';
import '../../features/portfolio/domain/usecases/calculate_green_score.dart';
import '../../features/portfolio/domain/usecases/get_esg_data.dart';
import '../../features/portfolio/domain/usecases/get_stock_price.dart';
import '../../features/portfolio/domain/usecases/portfolio_usecases.dart';
import '../../features/portfolio/domain/usecases/search_stocks.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //  Infrastructure
  sl.registerLazySingleton<IStockRemoteDataSource>(
      () => StockRemoteDataSource());
  sl.registerLazySingleton<IEsgDataSource>(() => EsgDataSource());
  sl.registerLazySingleton(() => PortfolioLocalDataSource());
  sl.registerLazySingleton(() => CurrencyService());

  //  Repositories
  sl.registerLazySingleton<IStockRepository>(
    () => StockRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<IEsgRepository>(
    () => EsgRepositoryImpl(sl()),
  );
  sl.registerLazySingleton<IPortfolioRepository>(
    () => PortfolioRepositoryImpl(sl(), sl(), sl()),
  );

  //  Use Cases
  sl.registerLazySingleton(() => GetStockPrice(sl()));
  sl.registerLazySingleton(() => GetEsgData(sl()));
  sl.registerLazySingleton(() => SearchStocks(sl()));
  sl.registerLazySingleton(() => GetPortfolio(sl()));
  sl.registerLazySingleton(() => AddToPortfolio(sl()));
  sl.registerLazySingleton(() => RemoveFromPortfolio(sl()));
  sl.registerLazySingleton(() => const CalculateGreenScore());

  //  State Management
  sl.registerFactory(() => CurrencyCubit(sl()));
}
