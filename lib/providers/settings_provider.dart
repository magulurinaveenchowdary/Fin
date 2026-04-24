import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/app_modules.dart';
import '../data/models/salary_config.dart';
import '../data/datasources/hive_datasource.dart';

// ─── Module Visibility Provider ──────────────────────────────────────────────

final appModulesProvider =
    StateNotifierProvider<AppModulesNotifier, AppModules>((ref) {
  final box = Hive.box<dynamic>(HiveDatasource.settingsBox);
  return AppModulesNotifier(box);
});

class AppModulesNotifier extends StateNotifier<AppModules> {
  final Box<dynamic> _box;
  static const _modulesKey = 'app_modules';

  AppModulesNotifier(this._box) : super(const AppModules()) {
    _load();
  }

  void _load() {
    final data = _box.get(_modulesKey);
    if (data != null && data is Map) {
      state = AppModules.fromMap(data);
    }
  }

  Future<void> _save(AppModules modules) async {
    await _box.put(_modulesKey, modules.toMap());
    state = modules;
  }

  Future<void> toggleTransactions(bool enabled) => _save(state.copyWith(transactions: enabled));
  Future<void> toggleEMI(bool enabled) => _save(state.copyWith(emi: enabled));
  Future<void> toggleSubscriptions(bool enabled) => _save(state.copyWith(subscriptions: enabled));
  Future<void> toggleDebts(bool enabled) => _save(state.copyWith(debts: enabled));
  Future<void> toggleAnalytics(bool enabled) => _save(state.copyWith(analytics: enabled));
}

// ─── Salary / Existing Settings Provider ─────────────────────────────────────

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SalaryConfig>((ref) {
  final box = Hive.box<dynamic>(HiveDatasource.settingsBox);
  return SettingsNotifier(box);
});

class SettingsNotifier extends StateNotifier<SalaryConfig> {
  final Box<dynamic> _box;
  static const String _salaryKey = 'salary_config';

  SettingsNotifier(this._box) : super(SalaryConfig()) {
    _loadSettings();
  }

  void _loadSettings() {
    final data = _box.get(_salaryKey);
    if (data != null) {
      state = data as SalaryConfig;
    }
  }

  Future<void> updateSalaryConfig(SalaryConfig config) async {
    await _box.put(_salaryKey, config);
    state = config;
  }
}
