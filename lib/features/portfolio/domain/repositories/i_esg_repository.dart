import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/esg_data.dart';

abstract class IEsgRepository {
  Future<Either<Failure, EsgData>> getEsgData(String symbol);
}
