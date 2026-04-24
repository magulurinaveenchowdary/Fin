import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../data/models/subscription.dart';
import '../data/datasources/hive_datasource.dart';

final subscriptionProvider = StateNotifierProvider<SubscriptionNotifier, List<Subscription>>((ref) {
  final box = Hive.box<Subscription>(HiveDatasource.subscriptionsBox);
  return SubscriptionNotifier(box);
});

class SubscriptionNotifier extends StateNotifier<List<Subscription>> {
  final Box<Subscription> _box;

  SubscriptionNotifier(this._box) : super([]) {
    _loadSubscriptions();
  }

  void _loadSubscriptions() {
    state = _box.values.toList();
  }

  Future<void> addSubscription(Subscription sub) async {
    await _box.put(sub.id, sub);
    _loadSubscriptions();
  }

  Future<void> deleteSubscription(String id) async {
    await _box.delete(id);
    _loadSubscriptions();
  }

  double get totalMonthlyCost => state
      .where((s) => s.isActive)
      .fold(0, (sum, s) {
        if (s.cycle == BillingCycle.monthly) return sum + s.amount;
        if (s.cycle == BillingCycle.annual) return sum + (s.amount / 12);
        if (s.cycle == BillingCycle.quarterly) return sum + (s.amount / 3);
        return sum;
      });
}
