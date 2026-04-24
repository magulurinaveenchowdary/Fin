import 'package:hive/hive.dart';

part 'emi.g.dart';

@HiveType(typeId: 2)
class EMI extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String loanName;
  
  @HiveField(2)
  final String lenderName;
  
  @HiveField(3)
  final double principal;
  
  @HiveField(4)
  final double interestRate;
  
  @HiveField(5)
  final int tenureMonths;
  
  @HiveField(6)
  final DateTime startDate;
  
  @HiveField(7)
  final double emiAmount;
  
  @HiveField(8)
  final List<String> paidMonths; // Stores "YYYY-MM"
  
  @HiveField(9)
  final bool isActive;

  EMI({
    required this.id,
    required this.loanName,
    required this.lenderName,
    required this.principal,
    required this.interestRate,
    required this.tenureMonths,
    required this.startDate,
    required this.emiAmount,
    this.paidMonths = const [],
    this.isActive = true,
  });
}
