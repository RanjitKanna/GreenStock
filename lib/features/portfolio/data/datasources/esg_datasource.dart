import '../../domain/entities/esg_data.dart';
import '../models/esg_model.dart';

abstract class IEsgDataSource {
  Future<EsgData> getEsgData(String symbol);
}

class EsgDataSource implements IEsgDataSource {
  @override
  Future<EsgData> getEsgData(String symbol) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return EsgModel.forSymbol(symbol);
  }
}
