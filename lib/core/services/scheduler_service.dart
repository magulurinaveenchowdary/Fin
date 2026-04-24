import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../providers/transaction_provider.dart';
import '../../providers/settings_provider.dart';
import '../../data/models/transaction.dart';
import 'notification_service.dart';

class SchedulerService {
  final Ref ref;
  SchedulerService(this.ref);

  Future<void> checkAndProcessSalary() async {
    final config = ref.read(settingsProvider);
    if (!config.isEnabled || config.amount <= 0) return;

    final now = DateTime.now();
    if (now.day != config.creditDay) return;

    // Check if salary already credited this month
    final transactions = ref.read(transactionsProvider);
    final alreadyCredited = transactions.any((t) =>
        t.categoryId == 'Salary' &&
        t.date.month == now.month &&
        t.date.year == now.year);

    if (!alreadyCredited) {
      final salaryTxn = Transaction(
        id: const Uuid().v4(),
        type: TransactionType.income,
        amount: config.amount,
        categoryId: 'Salary',
        note: 'Auto-credited Salary',
        date: DateTime.now(),
      );

      await ref.read(transactionsProvider.notifier).addTransaction(salaryTxn);
      await NotificationService().showInstantNotification(
        '💰 Salary Credited!',
        '₹${config.amount.toStringAsFixed(0)} has been added to your balance.',
      );
    }
  }

  Future<void> checkUpcomingEMIDues() async {
    // Future: schedule notifications 1-3 days before EMI due
  }
}

final schedulerServiceProvider = Provider<SchedulerService>((ref) => SchedulerService(ref));
