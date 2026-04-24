import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/debt.dart';
import '../data/datasources/hive_datasource.dart';

final debtProvider = StateNotifierProvider<DebtNotifier, List<Debt>>((ref) {
  final box = Hive.box<Debt>(HiveDatasource.debtsBox);
  return DebtNotifier(box);
});

class DebtNotifier extends StateNotifier<List<Debt>> {
  final Box<Debt> _box;

  DebtNotifier(this._box) : super([]) {
    _loadDebts();
  }

  void _loadDebts() {
    state = _box.values.toList();
  }

  Future<void> addDebt(Debt debt) async {
    await _box.put(debt.id, debt);
    _loadDebts();
  }

  Future<void> deleteDebt(String id) async {
    await _box.delete(id);
    _loadDebts();
  }

  Future<void> updateRepayment(String id, double paidAmount) async {
    final debt = _box.get(id);
    if (debt != null) {
      final updatedDebt = Debt(
        id: debt.id,
        type: debt.type,
        personName: debt.personName,
        personPhone: debt.personPhone,
        totalAmount: debt.totalAmount,
        paidAmount: paidAmount,
        date: debt.date,
        dueDate: debt.dueDate,
        purpose: debt.purpose,
        isSettled: paidAmount >= debt.totalAmount,
      );
      await _box.put(id, updatedDebt);
      _loadDebts();
    }
  }

  double get netDebtPosition {
    double iOwe = state
        .where((d) => d.type == DebtType.iOwe && !d.isSettled)
        .fold(0, (sum, d) => sum + (d.totalAmount - d.paidAmount));
    double theyOwe = state
        .where((d) => d.type == DebtType.theyOwe && !d.isSettled)
        .fold(0, (sum, d) => sum + (d.totalAmount - d.paidAmount));
    return theyOwe - iOwe;
  }
}
