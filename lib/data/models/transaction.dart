import 'package:hive/hive.dart';

part 'transaction.g.dart';

@HiveType(typeId: 0)
enum TransactionType {
  @HiveField(0)
  income,
  @HiveField(1)
  expense,
}

@HiveType(typeId: 1)
class Transaction extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final TransactionType type;
  
  @HiveField(2)
  final double amount;
  
  @HiveField(3)
  final String categoryId;
  
  @HiveField(4)
  final String? note;
  
  @HiveField(5)
  final DateTime date;
  
  @HiveField(6)
  final bool isRecurring;
  
  @HiveField(7)
  final String? recurrenceRule; // simplified for now
  
  @HiveField(8)
  final String? attachmentPath;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.date,
    this.isRecurring = false,
    this.recurrenceRule,
    this.attachmentPath,
  });
}
