import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/esg_data.dart';
import '../../domain/repositories/i_esg_repository.dart';
import '../datasources/esg_datasource.dart';

class EsgRepositoryImpl implements IEsgRepository {
  const EsgRepositoryImpl(this._ds);
  final IEsgDataSource _ds;

  @override
  Future<Either<Failure, EsgData>> getEsgData(String symbol) async {
    try {
      final data = await _ds.getEsgData(symbol);
      return Right(data);
    } catch (e) {
      return Left(ServerFailure('$e'));
    }
  }
}
