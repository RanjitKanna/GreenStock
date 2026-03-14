import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/esg_data.dart';
import '../repositories/i_esg_repository.dart';

class GetEsgData {
  const GetEsgData(this._repository);
  final IEsgRepository _repository;

  Future<Either<Failure, EsgData>> call(String symbol) =>
      _repository.getEsgData(symbol.toUpperCase().trim());
}
