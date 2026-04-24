import 'package:hive/hive.dart';

part 'subscription.g.dart';

@HiveType(typeId: 3)
enum BillingCycle {
  @HiveField(0)
  monthly,
  @HiveField(1)
  quarterly,
  @HiveField(2)
  annual,
}

@HiveType(typeId: 4)
class Subscription extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String iconKey;
  
  @HiveField(3)
  final double amount;
  
  @HiveField(4)
  final BillingCycle cycle;
  
  @HiveField(5)
  final int billingDay;
  
  @HiveField(6)
  final DateTime startDate;
  
  @HiveField(7)
  final bool isActive;
  
  @HiveField(8)
  final String category;

  Subscription({
    required this.id,
    required this.name,
    required this.iconKey,
    required this.amount,
    required this.cycle,
    required this.billingDay,
    required this.startDate,
    this.isActive = true,
    required this.category,
  });
}
