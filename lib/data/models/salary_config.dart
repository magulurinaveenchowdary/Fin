import 'package:hive/hive.dart';

part 'salary_config.g.dart';

@HiveType(typeId: 8)
class SalaryConfig extends HiveObject {
  @HiveField(0)
  final bool isEnabled;
  
  @HiveField(1)
  final double amount;
  
  @HiveField(2)
  final int creditDay;
  
  @HiveField(3)
  final String currency;

  SalaryConfig({
    this.isEnabled = false,
    this.amount = 0,
    this.creditDay = 1,
    this.currency = 'INR',
  });
}
