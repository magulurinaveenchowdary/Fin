import 'package:hive/hive.dart';

part 'budget.g.dart';

@HiveType(typeId: 7)
class Budget extends HiveObject {
  @HiveField(0)
  final String categoryId;
  
  @HiveField(1)
  final double monthlyLimit;
  
  @HiveField(2)
  final int month;
  
  @HiveField(3)
  final int year;

  Budget({
    required this.categoryId,
    required this.monthlyLimit,
    required this.month,
    required this.year,
  });
}
