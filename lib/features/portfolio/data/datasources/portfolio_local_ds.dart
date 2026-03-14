import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/portfolio_entry_model.dart';

class PortfolioLocalDataSource {
  static const String _boxName = 'portfolio';

  Future<Box> _openBox() => Hive.openBox(_boxName);

  Future<List<PortfolioEntry>> getAll() async {
    final box = await _openBox();
    return box.values
        .map((v) => PortfolioEntry.fromJson(
              Map<String, dynamic>.from(jsonDecode(v as String)),
            ))
        .toList();
  }

  Future<void> save(PortfolioEntry entry) async {
    final box = await _openBox();
    await box.put(entry.symbol, jsonEncode(entry.toJson()));
  }

  Future<void> delete(String symbol) async {
    final box = await _openBox();
    await box.delete(symbol);
  }

  Future<bool> contains(String symbol) async {
    final box = await _openBox();
    return box.containsKey(symbol);
  }
}
