import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/transaction.dart';
import '../data/datasources/hive_datasource.dart';

final transactionsProvider = StateNotifierProvider<TransactionNotifier, List<Transaction>>((ref) {
  final box = Hive.box<Transaction>(HiveDatasource.transactionsBox);
  return TransactionNotifier(box);
});

class TransactionNotifier extends StateNotifier<List<Transaction>> {
  final Box<Transaction> _box;

  TransactionNotifier(this._box) : super([]) {
    _loadTransactions();
  }

  void _loadTransactions() {
    state = _box.values.toList()..sort((a, b) => b.date.compareTo(a.date));
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _box.put(transaction.id, transaction);
    _loadTransactions();
  }

  Future<void> deleteTransaction(String id) async {
    await _box.delete(id);
    _loadTransactions();
  }

  double get totalIncome => state
      .where((t) => t.type == TransactionType.income)
      .fold(0, (sum, t) => sum + t.amount);

  double get totalExpense => state
      .where((t) => t.type == TransactionType.expense)
      .fold(0, (sum, t) => sum + t.amount);

  double get balance => totalIncome - totalExpense;
}
