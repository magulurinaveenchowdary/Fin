import 'package:hive/hive.dart';

part 'debt.g.dart';

@HiveType(typeId: 5)
enum DebtType {
  @HiveField(0)
  iOwe,
  @HiveField(1)
  theyOwe,
}

@HiveType(typeId: 6)
class Debt extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final DebtType type;
  
  @HiveField(2)
  final String personName;
  
  @HiveField(3)
  final String? personPhone;
  
  @HiveField(4)
  final double totalAmount;
  
  @HiveField(5)
  final double paidAmount;
  
  @HiveField(6)
  final DateTime date;
  
  @HiveField(7)
  final DateTime? dueDate;
  
  @HiveField(8)
  final String? purpose;
  
  @HiveField(9)
  final bool isSettled;

  Debt({
    required this.id,
    required this.type,
    required this.personName,
    this.personPhone,
    required this.totalAmount,
    this.paidAmount = 0,
    required this.date,
    this.dueDate,
    this.purpose,
    this.isSettled = false,
  });
}
