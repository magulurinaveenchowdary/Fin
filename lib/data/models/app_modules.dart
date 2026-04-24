/// Plain Dart model — no Hive adapter needed.
/// Serialised manually as a Map<String, dynamic> into the settings box.
class AppModules {
  final bool transactions;
  final bool emi;
  final bool subscriptions;
  final bool debts;
  final bool analytics;

  const AppModules({
    this.transactions = true,
    this.emi = true,
    this.subscriptions = true,
    this.debts = true,
    this.analytics = true,
  });

  AppModules copyWith({
    bool? transactions,
    bool? emi,
    bool? subscriptions,
    bool? debts,
    bool? analytics,
  }) {
    return AppModules(
      transactions: transactions ?? this.transactions,
      emi: emi ?? this.emi,
      subscriptions: subscriptions ?? this.subscriptions,
      debts: debts ?? this.debts,
      analytics: analytics ?? this.analytics,
    );
  }

  Map<String, dynamic> toMap() => {
        'transactions': transactions,
        'emi': emi,
        'subscriptions': subscriptions,
        'debts': debts,
        'analytics': analytics,
      };

  factory AppModules.fromMap(Map<dynamic, dynamic> map) => AppModules(
        transactions: (map['transactions'] as bool?) ?? true,
        emi: (map['emi'] as bool?) ?? true,
        subscriptions: (map['subscriptions'] as bool?) ?? true,
        debts: (map['debts'] as bool?) ?? true,
        analytics: (map['analytics'] as bool?) ?? true,
      );
}
