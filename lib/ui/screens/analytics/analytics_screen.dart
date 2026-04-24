import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:finval/providers/transaction_provider.dart';
import 'package:finval/providers/emi_provider.dart';
import 'package:finval/providers/subscription_provider.dart';
import 'package:finval/app/theme/colors.dart';
import 'package:finval/app/theme/text_styles.dart';
import 'package:finval/data/models/transaction.dart';
import 'package:intl/intl.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final transactions = ref.watch(transactionsProvider);
    final txnNotifier = ref.read(transactionsProvider.notifier);
    final emiNotifier = ref.read(emiProvider.notifier);
    final subNotifier = ref.read(subscriptionProvider.notifier);

    final totalIncome = txnNotifier.totalIncome;
    final totalExpense = txnNotifier.totalExpense;
    final totalEMI = emiNotifier.totalMonthlyEMIAmount;
    final totalSubs = subNotifier.totalMonthlyCost;

    final expenseByCategory = _groupByCategory(transactions);
    final barGroups = _buildBarGroups(transactions);

    return Scaffold(
      appBar: AppBar(title: Text('Analytics', style: AppTextStyles.h2)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --- Summary Tiles ---
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 2.0,
              children: [
                _summaryTile('Total Income', totalIncome, AppColors.success, Icons.arrow_downward_rounded),
                _summaryTile('Total Expenses', totalExpense, AppColors.danger, Icons.arrow_upward_rounded),
                _summaryTile('Monthly EMI', totalEMI, AppColors.accent, Icons.account_balance),
                _summaryTile('Monthly Subs', totalSubs, AppColors.info, Icons.subscriptions),
              ],
            ),
            const SizedBox(height: 28),

            // --- Cash Flow Pie Chart ---
            Text('Cash Flow', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            if (totalIncome == 0 && totalExpense == 0)
              _emptyChart('No transactions to display')
            else
              SizedBox(
                height: 220,
                child: Row(
                  children: [
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 3,
                          centerSpaceRadius: 40,
                          sections: [
                            if (totalIncome > 0)
                              PieChartSectionData(
                                value: totalIncome,
                                color: AppColors.success,
                                radius: 60,
                                title: '${(totalIncome / (totalIncome + totalExpense) * 100).toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            if (totalExpense > 0)
                              PieChartSectionData(
                                value: totalExpense,
                                color: AppColors.danger,
                                radius: 60,
                                title: '${(totalExpense / (totalIncome + totalExpense) * 100).toStringAsFixed(0)}%',
                                titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _legendItem(AppColors.success, 'Income', '₹${NumberFormat('#,##,###').format(totalIncome)}'),
                        const SizedBox(height: 12),
                        _legendItem(AppColors.danger, 'Expenses', '₹${NumberFormat('#,##,###').format(totalExpense)}'),
                        const SizedBox(height: 12),
                        _legendItem(
                          AppColors.primary,
                          'Savings',
                          '₹${NumberFormat('#,##,###').format((totalIncome - totalExpense).clamp(0, double.infinity))}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 28),

            // --- 7-Day Bar Chart ---
            Text('Last 7 Days', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            if (barGroups.every((g) => g.barRods.every((r) => r.toY == 0)))
              _emptyChart('No transactions in the last 7 days')
            else
              Container(
                height: 200,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.grey200),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: BarChart(
                  BarChartData(
                    barGroups: barGroups,
                    borderData: FlBorderData(show: false),
                    gridData: const FlGridData(show: false),
                    titlesData: FlTitlesData(
                      leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: (val, meta) {
                            final day = DateTime.now().subtract(Duration(days: 6 - val.toInt()));
                            return Text(DateFormat('E').format(day), style: const TextStyle(fontSize: 10));
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 28),

            // --- Category Breakdown ---
            Text('Spending by Category', style: AppTextStyles.h3),
            const SizedBox(height: 16),
            if (expenseByCategory.isEmpty)
              _emptyChart('No expenses yet')
            else
              ...expenseByCategory.entries.map((entry) {
                final pct = totalExpense > 0 ? entry.value / totalExpense : 0.0;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(entry.key, style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w500)),
                          Text('₹${NumberFormat('#,##,###').format(entry.value)}',
                              style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.bold, color: AppColors.danger)),
                        ],
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: pct,
                          minHeight: 6,
                          backgroundColor: AppColors.grey100,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.danger),
                        ),
                      ),
                    ],
                  ),
                );
              }),

            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Map<String, double> _groupByCategory(List<Transaction> transactions) {
    final Map<String, double> map = {};
    for (var t in transactions.where((t) => t.type == TransactionType.expense)) {
      map[t.categoryId] = (map[t.categoryId] ?? 0) + t.amount;
    }
    final sorted = Map.fromEntries(map.entries.toList()..sort((a, b) => b.value.compareTo(a.value)));
    return sorted;
  }

  List<BarChartGroupData> _buildBarGroups(List<Transaction> transactions) {
    return List.generate(7, (i) {
      final date = DateTime.now().subtract(Duration(days: 6 - i));
      final dayTxns = transactions.where((t) =>
          t.date.year == date.year && t.date.month == date.month && t.date.day == date.day);
      final income = dayTxns.where((t) => t.type == TransactionType.income).fold(0.0, (s, t) => s + t.amount);
      final expense = dayTxns.where((t) => t.type == TransactionType.expense).fold(0.0, (s, t) => s + t.amount);
      return BarChartGroupData(x: i, barRods: [
        BarChartRodData(toY: income, color: AppColors.success, width: 10, borderRadius: BorderRadius.circular(4)),
        BarChartRodData(toY: expense, color: AppColors.danger, width: 10, borderRadius: BorderRadius.circular(4)),
      ]);
    });
  }

  Widget _summaryTile(String label, double value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w500)),
                Text('₹${NumberFormat('#,##,###').format(value)}',
                    style: TextStyle(fontSize: 14, color: color, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legendItem(Color color, String label, String value) {
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: AppColors.grey600)),
            Text(value, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ],
    );
  }

  Widget _emptyChart(String msg) {
    return Container(
      height: 80,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(msg, style: AppTextStyles.bodySmall.copyWith(color: AppColors.grey500)),
    );
  }
}
