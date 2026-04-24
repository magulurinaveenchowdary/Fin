import 'dart:math';

class EMICalculator {
  static double calculateEMI({
    required double principal,
    required double annualRate,
    required int tenureMonths,
  }) {
    if (principal == 0 || tenureMonths == 0) return 0;
    
    // Monthly interest rate
    double r = annualRate / (12 * 100);
    
    if (r == 0) return principal / tenureMonths;

    // EMI formula: [P * r * (1 + r)^n] / [(1 + r)^n - 1]
    double emi = (principal * r * pow(1 + r, tenureMonths)) / (pow(1 + r, tenureMonths) - 1);
    
    return double.parse(emi.toStringAsFixed(2));
  }

  static double calculateTotalPayable(double emi, int tenureMonths) {
    return double.parse((emi * tenureMonths).toStringAsFixed(2));
  }

  static double calculateTotalInterest(double totalPayable, double principal) {
    return double.parse((totalPayable - principal).toStringAsFixed(2));
  }
}
