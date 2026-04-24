import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/emi.dart';
import '../data/datasources/hive_datasource.dart';

final emiProvider = StateNotifierProvider<EMINotifier, List<EMI>>((ref) {
  final box = Hive.box<EMI>(HiveDatasource.emisBox);
  return EMINotifier(box);
});

class EMINotifier extends StateNotifier<List<EMI>> {
  final Box<EMI> _box;

  EMINotifier(this._box) : super([]) {
    _loadEMIs();
  }

  void _loadEMIs() {
    state = _box.values.toList();
  }

  Future<void> addEMI(EMI emi) async {
    await _box.put(emi.id, emi);
    _loadEMIs();
  }

  Future<void> deleteEMI(String id) async {
    await _box.delete(id);
    _loadEMIs();
  }

  Future<void> markAsPaid(String emiId, String monthYear) async {
    final emi = _box.get(emiId);
    if (emi != null) {
      final updatedPaidMonths = List<String>.from(emi.paidMonths);
      if (!updatedPaidMonths.contains(monthYear)) {
        updatedPaidMonths.add(monthYear);
        final updatedEMI = EMI(
          id: emi.id,
          loanName: emi.loanName,
          lenderName: emi.lenderName,
          principal: emi.principal,
          interestRate: emi.interestRate,
          tenureMonths: emi.tenureMonths,
          startDate: emi.startDate,
          emiAmount: emi.emiAmount,
          paidMonths: updatedPaidMonths,
          isActive: emi.isActive,
        );
        await _box.put(emiId, updatedEMI);
        _loadEMIs();
      }
    }
  }

  double get totalMonthlyEMIAmount => state
      .where((e) => e.isActive)
      .fold(0, (sum, e) => sum + e.emiAmount);
}
