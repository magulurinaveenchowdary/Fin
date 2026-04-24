import 'package:hive_flutter/hive_flutter.dart';
import '../models/transaction.dart';
import '../models/emi.dart';
import '../models/subscription.dart';
import '../models/debt.dart';
import '../models/budget.dart';
import '../models/salary_config.dart';

class HiveDatasource {
  static const String transactionsBox = 'transactions';
  static const String emisBox = 'emis';
  static const String subscriptionsBox = 'subscriptions';
  static const String debtsBox = 'debts';
  static const String budgetsBox = 'budgets';
  static const String settingsBox = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();

    // Register Adapters
    Hive.registerAdapter(TransactionTypeAdapter());
    Hive.registerAdapter(TransactionAdapter());
    Hive.registerAdapter(EMIAdapter());
    Hive.registerAdapter(BillingCycleAdapter());
    Hive.registerAdapter(SubscriptionAdapter());
    Hive.registerAdapter(DebtTypeAdapter());
    Hive.registerAdapter(DebtAdapter());
    Hive.registerAdapter(BudgetAdapter());
    Hive.registerAdapter(SalaryConfigAdapter());

    // Open Boxes
    await Hive.openBox<Transaction>(transactionsBox);
    await Hive.openBox<EMI>(emisBox);
    await Hive.openBox<Subscription>(subscriptionsBox);
    await Hive.openBox<Debt>(debtsBox);
    await Hive.openBox<Budget>(budgetsBox);
    await Hive.openBox<dynamic>(settingsBox);
  }
}
